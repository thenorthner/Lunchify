const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { JWT_SECRET, USER_TOKEN_EXPIRY, ADMIN_TOKEN_EXPIRY } = require('../config/jwt');
const bcrypt = require("bcryptjs");
const mysqlPool = require('../db');
const { sendSMS } = require('../services/sms.service');
const rateLimit = require('express-rate-limit');
const { logAudit } = require('../utils/logger');
const { requireAuth, requireITAdmin } = require('../middleware/auth.middleware');
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

function assertStrongPassword(pw) {
  if (typeof pw !== 'string') throw new Error('Password must be a string');
  if (pw.length < 8) throw new Error('Password must be at least 8 characters long');
  if (!/[A-Z]/.test(pw)) throw new Error('Password must contain at least one uppercase letter');
  if (!/[a-z]/.test(pw)) throw new Error('Password must contain at least one lowercase letter');
  if (!/[0-9]/.test(pw)) throw new Error('Password must contain at least one digit');
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pw)) throw new Error('Password must contain at least one special character');
}

// Rate limiter for OTP requests: limit to 5 requests per 10 minutes per IP
const otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 5,
  message: { message: 'Too many OTP requests, please try again after 10 minutes' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Rate limiter for logins: limit to 10 requests per 10 minutes per IP
const loginLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 10,
  message: { message: 'Too many login attempts, please try again after 10 minutes' },
  standardHeaders: true,
  legacyHeaders: false,
});

/* ---------------------------------------------------
   1️⃣ CHECK EMPLOYEE ID (AUTO-FILL)
--------------------------------------------------- */
router.get('/check-id/:employeeId', async (req, res) => {
  try {
    const employeeId = req.params.employeeId.trim().toUpperCase();
    console.log(`[AUTH] check-id requested for: ${employeeId}`);

    const [rows] = await mysqlPool.query(
      'SELECT id, name, department, phone, is_registered, is_active FROM users WHERE id = ?',
      [employeeId]
    );

    if (rows.length === 0 || rows[0].is_active !== 1) {
      return res.json({ eligible: false, message: 'Invalid or inactive employee ID' });
    }

    if (rows[0].is_registered === 1) {
      return res.json({ eligible: false, message: 'Already registered', name: rows[0].name });
    }

    // Mask phone number - show only last 4 digits
    let maskedPhone = rows[0].phone;
    if (maskedPhone) {
      const phoneStr = maskedPhone.toString();
      maskedPhone = '*'.repeat(Math.max(0, phoneStr.length - 4)) + phoneStr.slice(-4);
    }

    res.json({
      name: rows[0].name,
      department: rows[0].department,
      phone: maskedPhone
    });
  } catch (err) {
    console.error('❌ check-id error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   1.5️⃣ ADMIN CHECK EMPLOYEE ID (ALL STATUSES)
--------------------------------------------------- */
router.get('/admin-check-id/:employeeId', requireAuth, requireITAdmin, async (req, res) => {
  try {
    const employeeId = req.params.employeeId.trim().toUpperCase();

    const [rows] = await mysqlPool.query(
      'SELECT id, name, department, phone, is_registered, is_active, role FROM users WHERE id = ?',
      [employeeId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    const user = rows[0];

    // Mask phone number - show only last 4 digits
    if (user.phone) {
      const phone = user.phone.toString();
      user.phone = '*'.repeat(Math.max(0, phone.length - 4)) + phone.slice(-4);
    }

    res.json({
      employee_id: user.id,
      name: user.name,
      department: user.department,
      phone: user.phone,
      role: user.role,
      is_active: user.is_active === 1
    });
  } catch (err) {
    console.error('❌ admin-check-id error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   2️⃣ REQUEST OTP (SIGNUP)
--------------------------------------------------- */
router.post('/login-request', otpLimiter, async (req, res) => {
  try {
    const { employeeId, phone } = req.body;
    const formattedId = employeeId?.trim().toUpperCase();
    const isMasked = phone && phone.includes('*');
    let normalizedPhone = phone?.trim().replace(/[^0-9]/g, '');

    if (!formattedId || !normalizedPhone) {
      return res.status(400).json({ message: 'Employee ID & phone required' });
    }

    const [users] = await mysqlPool.query(
      'SELECT id, phone, is_registered, is_active FROM users WHERE id = ? AND is_active = 1',
      [formattedId]
    );

    if (users.length === 0) {
      return res.json({ message: 'If eligible, an OTP has been sent.' });
    }

    if (users[0].is_registered === 1) {
      return res.json({ message: 'If eligible, an OTP has been sent.' });
    }

    const registeredPhone = (users[0].phone || '').replace(/[^0-9]/g, '');
    if (!registeredPhone) {
      return res.json({ message: 'If eligible, an OTP has been sent.' });
    }

    if (isMasked) {
      if (!registeredPhone.endsWith(normalizedPhone)) {
        return res.json({ message: 'If eligible, an OTP has been sent.' });
      }
      // Overwrite normalizedPhone with the real phone so OTP uses the correct number
      normalizedPhone = registeredPhone;
    } else {
      if (registeredPhone !== normalizedPhone) {
        return res.json({ message: 'If eligible, an OTP has been sent.' });
      }
    }

    const otp = crypto.randomInt(100000, 999999).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    // Delete old OTPs
    await mysqlPool.query(
      'DELETE FROM otp_verifications WHERE phone_number = ? OR employee_id = ?',
      [normalizedPhone, formattedId]
    );

    await mysqlPool.query(
      'INSERT INTO otp_verifications (employee_id, phone_number, otp_code, expires_at) VALUES (?, ?, ?, ?)',
      [formattedId, normalizedPhone, otp, expiresAt]
    );

    const smsMessage = `OTP for Login in portal is ${otp} - SJVN Limited`;
    await sendSMS(normalizedPhone, smsMessage);

    res.json({ message: 'If eligible, an OTP has been sent.' });
  } catch (err) {
    console.error('❌ login-request error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   3️⃣ VERIFY OTP + SET PASSWORD
--------------------------------------------------- */
router.post('/verify-otp', otpLimiter, async (req, res) => {
  try {
    const { employeeId, phone, otp, password } = req.body;
    const formattedId = employeeId?.trim().toUpperCase();
    const isMasked = phone && phone.includes('*');
    let normalizedPhone = phone?.trim().replace(/[^0-9]/g, '');

    if (!formattedId || !normalizedPhone || !otp || !password) {
      return res.status(400).json({ message: 'All fields required' });
    }

    const [users] = await mysqlPool.query(
      'SELECT id, phone, is_registered FROM users WHERE id = ? AND is_active = 1',
      [formattedId]
    );
    if (users.length === 0 || users[0].is_registered === 1) {
      return res.status(400).json({ message: 'Invalid registration request' });
    }

    if (isMasked) {
      const registeredPhone = (users[0].phone || '').replace(/[^0-9]/g, '');
      if (registeredPhone.endsWith(normalizedPhone)) {
        normalizedPhone = registeredPhone;
      }
    }

    const [rows] = await mysqlPool.query(
      `SELECT id FROM otp_verifications
       WHERE employee_id = ? AND phone_number = ? AND otp_code = ?
       AND expires_at > NOW()
       ORDER BY created_at DESC LIMIT 1`,
      [formattedId, normalizedPhone, otp]
    );

    if (rows.length === 0) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    try {
      assertStrongPassword(password);
    } catch (e) {
      return res.status(400).json({ message: e.message });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await mysqlPool.query(
      'UPDATE users SET password = ?, phone = ?, is_registered = 1 WHERE id = ?',
      [hashedPassword, normalizedPhone, formattedId]
    );

    await mysqlPool.query('DELETE FROM otp_verifications WHERE id = ?', [rows[0].id]);

    res.json({ success: true, message: 'Account created successfully' });
  } catch (err) {
    console.error('❌ verify-otp error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   4️⃣ LOGIN WITH EMPLOYEE ID + PASSWORD
--------------------------------------------------- */
router.post('/login', loginLimiter, async (req, res) => {
  try {
    const { employeeId, password, deviceId } = req.body;
    const formattedId = employeeId.trim().toUpperCase();

    if (!employeeId || !password) {
      return res.status(400).json({ message: 'Employee ID & password required' });
    }

    const [rows] = await mysqlPool.query(
      `SELECT id, admin_id, name, password, portal_password, role, project_id, canteen_id,
              monthly_limit, last_coupon_reset_month, is_registered, is_active, designation
       FROM users WHERE id = ? OR admin_id = ?`,
      [formattedId, formattedId]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = rows[0];

    if (user.is_active !== 1) {
      return res.status(403).json({ message: 'Account is deactivated' });
    }
    if (user.is_registered !== 1) {
      return res.status(403).json({ message: 'Account not registered. Complete signup first.' });
    }
    if (!user.password && !user.portal_password) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Check and Reset Monthly Limit if needed
    const currentDate = new Date();
    const currentMonthStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}`;
    if (user.last_coupon_reset_month !== currentMonthStr) {
      await mysqlPool.query(
        'UPDATE users SET coupons_left = monthly_limit, coupons_used = 0, last_coupon_reset_month = ? WHERE id = ?',
        [currentMonthStr, user.id]
      );
    }

    // ✅ Dynamic role assignment based on login method
    let isMatch = false;
    let actualRole = 'employee';

    // 1. Try Employee password if the ID matches the employee ID
    if (user.id === formattedId && user.password) {
      const match = await bcrypt.compare(password, user.password);
      if (match) {
        isMatch = true;
        // If they have a separate admin_id set, logging in with Employee ID logs them in as 'employee'
        // Also, if their role is it_admin or hr_admin, they can only be an 'employee' on the mobile app.
        if (user.admin_id || ['it_admin', 'hr_admin'].includes(user.role)) {
          actualRole = 'employee';
        } else {
          actualRole = user.role;
        }
      }
    }

    // 2. If not matched, try Portal/Admin password if the ID matches the admin_id
    if (!isMatch && user.admin_id && user.admin_id.toUpperCase() === formattedId && user.portal_password) {
      const match = await bcrypt.compare(password, user.portal_password);
      if (match) {
        if (['it_admin', 'hr_admin'].includes(user.role)) {
          return res.status(403).json({ message: 'IT & HR Admins must use the Web Portal for admin access.' });
        }
        isMatch = true;
        actualRole = user.role;
      }
    }

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const sessionToken = require('crypto').randomBytes(32).toString('hex');
    const clientDeviceId = deviceId || 'unknown_device';

    await mysqlPool.query(
      'UPDATE users SET session_token = ?, device_id = ? WHERE id = ?',
      [sessionToken, clientDeviceId, user.id]
    );

    const checkGmOrAbove = (designation) => {
      if (!designation) return false;
      const d = designation.toLowerCase();
      // Exclude Deputy and Assistant variants
      if (d.includes('dy.') || d.includes('dy ') || d.includes('deputy') || d.includes('asst') || d.includes('assistant') || d.includes('jr') || d.includes('junior')) {
        return false;
      }
      return d.includes('general manager') || 
             d.includes('director') || 
             d.includes('chairman') || 
             d.includes('cvo') || 
             d.includes('chief vigilance officer');
    };

    const isGmOrAbove = checkGmOrAbove(user.designation);

    const token = jwt.sign(
      { 
        id: user.id, 
        role: actualRole, 
        project_id: user.project_id, 
        canteen_id: user.canteen_id,
        is_gm_or_above: isGmOrAbove,
        sessionToken,
        jti: crypto.randomUUID()
      },
      JWT_SECRET,
      { expiresIn: USER_TOKEN_EXPIRY, issuer: 'lunchify-api', audience: 'lunchify-mobile' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        role: actualRole,
        project_id: user.project_id,
        canteen_id: user.canteen_id,
        designation: user.designation,
        is_gm_or_above: isGmOrAbove
      },
    });
  } catch (err) {
    console.error('❌ login error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   5️⃣ ADMIN LOGIN (WEBSITE)
--------------------------------------------------- */
router.post('/admin/login', loginLimiter, async (req, res) => {
  try {
    const { employeeId, password, deviceId } = req.body;
    const formattedId = employeeId.trim().toUpperCase();

    if (!employeeId || !password) {
      return res.status(400).json({ message: 'Admin ID & password required' });
    }

    const [rows] = await mysqlPool.query(
      'SELECT u.id, u.name, u.portal_password, u.role, u.project_id, u.canteen_id, u.is_active, c.name as canteen_name FROM users u LEFT JOIN canteens c ON u.canteen_id = c.id WHERE (u.id = ? OR u.admin_id = ?) AND u.is_active = 1',
      [formattedId, formattedId]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = rows[0];

    // Ensure they have an admin role
    if (!['canteen_admin', 'hr_admin', 'it_admin'].includes(user.role)) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.portal_password || '');
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate unique session token for single-device restriction
    const sessionToken = crypto.randomBytes(32).toString('hex');
    const clientDeviceId = deviceId || 'unknown_admin_device';

    // Update database with active session details
    await mysqlPool.query(
      'UPDATE users SET session_token = ?, device_id = ? WHERE id = ?',
      [sessionToken, clientDeviceId, user.id]
    );

    const token = jwt.sign(
      { 
        id: user.id, 
        role: user.role, 
        project_id: user.project_id, 
        canteen_id: user.canteen_id,
        sessionToken,
        jti: crypto.randomUUID()
      },
      JWT_SECRET,
      { expiresIn: ADMIN_TOKEN_EXPIRY, issuer: 'lunchify-api', audience: 'lunchify-admin' }
    );

    res.cookie('admin_session', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 8 * 60 * 60 * 1000, // 8 hours
    });

    let allowedTabs = [];
    if (user.role === 'canteen_admin') {
      allowedTabs = ["menu", "reports", "canteen_billing", "orders", "scan_history"];
    } else if (user.role === 'hr_admin') {
      allowedTabs = ["billing", "transfers", "item_feedbacks"];
    } else if (user.role === 'it_admin') {
      allowedTabs = ["canteen_projects", "feedbacks", "item_feedbacks", "admin_accounts"];
    }

    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        name: user.name,
        role: user.role,
        project_id: user.project_id,
        canteen_id: user.canteen_id,
        canteen_name: user.canteen_name,
        allowedTabs
      },
    });
  } catch (err) {
    console.error('❌ admin login error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});


/* ---------------------------------------------------
   6️⃣ FORGOT PASSWORD (REQUEST OTP FOR RESET)
--------------------------------------------------- */
router.post('/forgot-password', otpLimiter, async (req, res) => {
  try {
    const { employeeId, phone } = req.body;
    const formattedId = employeeId?.trim().toUpperCase();
    const normalizedPhone = phone?.trim().replace(/[^0-9]/g, '');

    if (!formattedId || !normalizedPhone) {
      return res.status(400).json({ message: 'Employee ID & phone required' });
    }

    // Verify if the user exists and matches the ID and Phone
    const [users] = await mysqlPool.query(
      'SELECT id, phone FROM users WHERE id = ? AND is_active = 1',
      [formattedId]
    );

    if (users.length === 0) {
      return res.json({ success: true, message: 'If eligible, an OTP has been sent.' });
    }

    const registeredPhone = (users[0].phone || '').replace(/[^0-9]/g, '');
    if (registeredPhone !== normalizedPhone) {
      return res.json({ success: true, message: 'If eligible, an OTP has been sent.' });
    }

    const otp = crypto.randomInt(100000, 999999).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await mysqlPool.query(
      'DELETE FROM otp_verifications WHERE phone_number = ? OR employee_id = ?',
      [normalizedPhone, formattedId]
    );

    await mysqlPool.query(
      'INSERT INTO otp_verifications (employee_id, phone_number, otp_code, expires_at) VALUES (?, ?, ?, ?)',
      [formattedId, normalizedPhone, otp, expiresAt]
    );

    const smsMessage = `OTP for Login in portal is ${otp} - SJVN Limited`;
    await sendSMS(normalizedPhone, smsMessage);

    res.json({ success: true, message: 'If eligible, an OTP has been sent.' });
  } catch (err) {
    console.error('❌ forgot-password error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   7️⃣ RESET PASSWORD (VERIFY OTP & UPDATE PASSWORD)
--------------------------------------------------- */
router.post('/reset-password', loginLimiter, async (req, res) => {
  try {
    const { employeeId, phone, otp, newPassword } = req.body;
    const formattedId = employeeId?.trim().toUpperCase();
    const normalizedPhone = phone?.trim().replace(/[^0-9]/g, '');

    if (!formattedId || !normalizedPhone || !otp || !newPassword) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    const [users] = await mysqlPool.query(
      'SELECT phone FROM users WHERE id = ? AND is_active = 1',
      [formattedId]
    );
    if (users.length === 0) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    const registeredPhone = (users[0].phone || '').replace(/[^0-9]/g, '');
    if (registeredPhone !== normalizedPhone) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    const [rows] = await mysqlPool.query(
      `SELECT id FROM otp_verifications
       WHERE employee_id = ? AND phone_number = ? AND otp_code = ?
       AND expires_at > NOW()
       ORDER BY created_at DESC LIMIT 1`,
      [formattedId, normalizedPhone, otp]
    );

    if (rows.length === 0) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    try {
      assertStrongPassword(newPassword);
    } catch (e) {
      return res.status(400).json({ message: e.message });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await mysqlPool.query(
      'UPDATE users SET password = ?, is_registered = 1, session_token = NULL WHERE id = ?',
      [hashedPassword, formattedId]
    );
    await mysqlPool.query('DELETE FROM otp_verifications WHERE id = ?', [rows[0].id]);

    res.json({ success: true, message: 'Password reset successfully' });
  } catch (err) {
    console.error('❌ reset-password error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   8️⃣ UPSERT USER / ROLE ASSIGNMENT (IT ADMIN ONLY)
--------------------------------------------------- */

router.post('/upsert-user', requireAuth, requireITAdmin, async (req, res) => {
  try {
    const { employeeId, admin_id, name, department, phone, password, role, project_id, canteen_id } = req.body;
    
    if (!employeeId || !name || !department || !phone || !role) {
      return res.status(400).json({ message: 'Employee ID, Name, Department, Phone, and Role are required' });
    }

    const formattedId = employeeId.trim().toUpperCase();
    const finalRoleId = role.trim();

    const ALLOWED_ROLES = ['employee', 'canteen_admin', 'hr_admin', 'it_admin', 'scanner'];
    if (!ALLOWED_ROLES.includes(finalRoleId)) {
      return res.status(400).json({ message: 'Invalid role' });
    }
    const finalProjectId = project_id || 1;
    const finalCanteenId = canteen_id || 1;
    const isAdmin = ['canteen_admin', 'hr_admin', 'it_admin', 'scanner'].includes(finalRoleId) ? 1 : 0;

    // Check if the user already exists
    const [rows] = await mysqlPool.query('SELECT id FROM users WHERE id = ?', [formattedId]);

    if (rows.length > 0) {
      // Update existing user
      let query = `
        UPDATE users 
        SET name = ?, department = ?, phone = ?, role = ?, project_id = ?, canteen_id = ?, is_registered = 1, is_admin = ?, admin_id = ?, is_active = 1
      `;
      const params = [name, department, phone, finalRoleId, finalProjectId, finalCanteenId, isAdmin, admin_id || null];

      if (password && password.trim() !== '') {
        try {
          assertStrongPassword(password);
        } catch (e) {
          return res.status(400).json({ message: e.message });
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        query += `, password = ?, portal_password = ?`;
        params.push(hashedPassword, hashedPassword);
      }

      query += ` WHERE id = ?`;
      params.push(formattedId);

      await mysqlPool.query(query, params);
      
      logAudit('USER_UPDATE', req.user.id, { 
        targetUser: formattedId, 
        role: finalRoleId, 
        project_id: finalProjectId, 
        canteen_id: finalCanteenId 
      });
      
      return res.json({ success: true, message: `User ${formattedId} updated successfully` });
    } else {
      // Insert new user
      if (!password || password.trim() === '') {
        return res.status(400).json({ message: 'Password is required for new users' });
      }

      try {
        assertStrongPassword(password);
      } catch (e) {
        return res.status(400).json({ message: e.message });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      await mysqlPool.query(
        `INSERT INTO users (id, name, department, phone, password, portal_password, role, project_id, canteen_id, is_registered, is_admin, admin_id, is_active, coupons_left, monthly_limit)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, 1, 16, 16)`,
        [formattedId, name, department, phone, hashedPassword, hashedPassword, finalRoleId, finalProjectId, finalCanteenId, isAdmin, admin_id || null]
      );

      logAudit('USER_CREATE', req.user.id, { 
        targetUser: formattedId, 
        role: finalRoleId, 
        project_id: finalProjectId, 
        canteen_id: finalCanteenId 
      });

      return res.json({ success: true, message: `User ${formattedId} created successfully` });
    }
  } catch (err) {
    console.error('❌ upsert-user error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   TOGGLE EMPLOYEE ACTIVE STATUS
--------------------------------------------------- */
router.patch('/toggle-active/:employeeId', requireAuth, requireITAdmin, async (req, res) => {
  try {
    const { employeeId } = req.params;
    const [rows] = await mysqlPool.query('SELECT id, name, is_active FROM users WHERE id = ?', [employeeId]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Employee not found' });
    }
    const currentStatus = rows[0].is_active;
    const isActive = currentStatus === 1 || currentStatus === true || currentStatus === '1';
    const newStatus = isActive ? 0 : 1;
    await mysqlPool.query('UPDATE users SET is_active = ? WHERE id = ?', [newStatus, employeeId]);
    
    // Audit log
    try {
      await mysqlPool.query(
        'INSERT INTO audit_logs (admin_id, action, target_user_id, details) VALUES (?, ?, ?, ?)',
        [req.user.id, newStatus === 1 ? 'REACTIVATE_USER' : 'DEACTIVATE_USER', employeeId, JSON.stringify({ name: rows[0].name })]
      );
    } catch (e) { console.error('Audit log error:', e); }
    
    res.json({ success: true, message: `Employee ${newStatus === 1 ? 'reactivated' : 'deactivated'} successfully`, is_active: newStatus });
  } catch (err) {
    console.error('Toggle active error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   9️⃣ LOGOUT
--------------------------------------------------- */
router.post('/logout', requireAuth, async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    const match = req.headers.cookie?.match(/(?:^|;\s*)admin_session=([^;]*)/);
    const cookieToken = match ? match[1] : null;

    let token = null;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.split(' ')[1];
    } else if (cookieToken) {
      token = cookieToken;
    }

    if (token) {
      // Invalidate the session token in the database
      await mysqlPool.query('UPDATE users SET session_token = NULL WHERE id = ?', [req.user.id]);
    }
    
    res.clearCookie('admin_session');
    res.json({ success: true, message: 'Logged out successfully' });
  } catch (err) {
    console.error('❌ logout error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   1️⃣0️⃣ SESSION VALIDATION (GET /me)
--------------------------------------------------- */
router.get('/me', requireAuth, async (req, res) => {
  try {
    const [rows] = await mysqlPool.query(
      'SELECT u.id, u.name, u.department, u.role, u.project_id, u.canteen_id, c.name as canteen_name FROM users u LEFT JOIN canteens c ON u.canteen_id = c.id WHERE u.id = ?',
      [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const u = rows[0];
    let allowedTabs = [];
    if (u.role === 'canteen_admin') {
      allowedTabs = ["menu", "reports", "canteen_billing", "orders", "scan_history"];
    } else if (u.role === 'hr_admin') {
      allowedTabs = ["billing", "transfers", "item_feedbacks"];
    } else if (u.role === 'it_admin') {
      allowedTabs = ["canteen_projects", "feedbacks", "item_feedbacks", "admin_accounts"];
    }

    res.json({ success: true, user: { ...u, allowedTabs } });
  } catch (err) {
    console.error('❌ /me error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

