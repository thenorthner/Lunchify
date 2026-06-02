const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require("bcryptjs");
const mysqlPool = require('../db');
const { sendSMS } = require('../services/sms.service');
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

/* ---------------------------------------------------
   1️⃣ CHECK EMPLOYEE ID (AUTO-FILL)
--------------------------------------------------- */
router.get('/check-id/:employeeId', async (req, res) => {
  try {
    const employeeId = req.params.employeeId.trim().toUpperCase();

    const [rows] = await mysqlPool.query(
      'SELECT id, name, department, phone, is_registered, last_coupon_reset_month, monthly_limit FROM users WHERE id = ?',
      [employeeId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Invalid Employee ID' });
    }

    if (rows[0].is_registered === 1) {
      return res.status(400).json({ 
        message: 'Employee already registered',
        data: {
          name: rows[0].name,
          department: rows[0].department,
          phone: rows[0].phone
        }
      });
    }

    // Check and Reset Monthly Limit if needed
    const currentDate = new Date();
    const currentMonthStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}`;
    if (rows[0].last_coupon_reset_month !== currentMonthStr) {
      await mysqlPool.query(
        'UPDATE users SET coupons_left = monthly_limit, coupons_used = 0, last_coupon_reset_month = ? WHERE id = ?',
        [currentMonthStr, employeeId]
      );
    }

    res.json({
      name: rows[0].name,
      department: rows[0].department,
    });
  } catch (err) {
    console.error('❌ check-id error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   2️⃣ REQUEST OTP (SIGNUP)
--------------------------------------------------- */
router.post('/login-request', async (req, res) => {
  try {
    const { employeeId, phone } = req.body;
    const formattedId = employeeId.trim().toUpperCase();

    if (!employeeId || !phone) {
      return res.status(400).json({ message: 'Employee ID & phone required' });
    }

    const [users] = await mysqlPool.query(
      'SELECT id, phone FROM users WHERE id = ?',
      [formattedId]
    );

    if (users.length === 0) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    if (!users[0].phone) {
      await mysqlPool.query(
        'UPDATE users SET phone = ? WHERE id = ?',
        [phone, formattedId]
      );
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await mysqlPool.query(
      'INSERT INTO otp_verifications (phone_number, otp_code, expires_at) VALUES (?, ?, ?)',
      [phone, otp, expiresAt]
    );

    // Send actual SMS text message using our integrated SMS service
    const smsMessage = `Your SJVN Lunchify signup OTP is ${otp}. Valid for 5 minutes. Please do not share this with anyone.`;
    await sendSMS(phone, smsMessage);

    res.json({ message: 'OTP sent successfully' });
  } catch (err) {
    console.error('❌ login-request error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   3️⃣ VERIFY OTP + SET PASSWORD
--------------------------------------------------- */
router.post('/verify-otp', async (req, res) => {
  try {
    const { employeeId, phone, otp, password } = req.body;
    const formattedId = employeeId.trim().toUpperCase();

    if (!otp || !password) {
      return res.status(400).json({ message: 'OTP & password required' });
    }

    const [rows] = await mysqlPool.query(
      `SELECT * FROM otp_verifications
       WHERE phone_number = ? AND otp_code = ?
       ORDER BY created_at DESC LIMIT 1`,
      [phone, otp]
    );

    if (rows.length === 0) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    if (new Date(rows[0].expires_at) < new Date()) {
      return res.status(400).json({ message: 'OTP expired' });
    }

    const hashedPassword = await bcrypt.hash(password, 10); // ✅ HASH

    await mysqlPool.query(
      'UPDATE users SET password = ?, is_registered = 1 WHERE id = ?',
      [hashedPassword, formattedId]
    );

    res.json({ success: true, message: 'Account created successfully' });
  } catch (err) {
    console.error('❌ verify-otp error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   4️⃣ LOGIN WITH EMPLOYEE ID + PASSWORD
--------------------------------------------------- */
router.post('/login', async (req, res) => {
  try {
    const { employeeId, password, deviceId } = req.body;
    const formattedId = employeeId.trim().toUpperCase();

    if (!employeeId || !password) {
      return res.status(400).json({ message: 'Employee ID & password required' });
    }

    const [rows] = await mysqlPool.query(
      'SELECT id, name, password, role, project_id, canteen_id, monthly_limit, last_coupon_reset_month FROM users WHERE id = ?',
      [formattedId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = rows[0];

    // Check and Reset Monthly Limit if needed
    const currentDate = new Date();
    const currentMonthStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}`;
    if (user.last_coupon_reset_month !== currentMonthStr) {
      await mysqlPool.query(
        'UPDATE users SET coupons_left = monthly_limit, coupons_used = 0, last_coupon_reset_month = ? WHERE id = ?',
        [currentMonthStr, user.id]
      );
    }

    // ✅ CORRECT bcrypt comparison
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid password' });
    }

    // Generate unique session token for single-device restriction
    const sessionToken = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
    const clientDeviceId = deviceId || 'unknown_device';

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
        sessionToken
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' } // Extended to 30 days for persistent logins
    );

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        role: user.role,
        project_id: user.project_id,
        canteen_id: user.canteen_id
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
router.post('/admin/login', async (req, res) => {
  try {
    const { employeeId, password, deviceId } = req.body;
    const formattedId = employeeId.trim().toUpperCase();

    if (!employeeId || !password) {
      return res.status(400).json({ message: 'Admin ID & password required' });
    }

    const [rows] = await mysqlPool.query(
      'SELECT id, name, password, role, project_id, canteen_id FROM users WHERE (id = ? OR admin_id = ?)',
      [formattedId, formattedId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = rows[0];

    // Ensure they have an admin role
    if (!['canteen_admin', 'hr_admin', 'it_admin'].includes(user.role)) {
      return res.status(403).json({ message: 'Access denied. You do not have admin permissions.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid password' });
    }

    // Generate unique session token for single-device restriction
    const sessionToken = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
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
        sessionToken
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        role: user.role,
        project_id: user.project_id,
        canteen_id: user.canteen_id
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
router.post('/forgot-password', async (req, res) => {
  try {
    const { employeeId, phone } = req.body;
    if (!employeeId || !phone) {
      return res.status(400).json({ message: 'Employee ID & phone required' });
    }
    const formattedId = employeeId.trim().toUpperCase();

    // Verify if the user exists and matches the ID and Phone
    const [users] = await mysqlPool.query(
      'SELECT id, phone FROM users WHERE id = ?',
      [formattedId]
    );

    if (users.length === 0) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    const user = users[0];
    if (user.phone !== phone) {
      return res.status(400).json({ message: 'Phone number does not match registered number' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await mysqlPool.query(
      'INSERT INTO otp_verifications (phone_number, otp_code, expires_at) VALUES (?, ?, ?)',
      [phone, otp, expiresAt]
    );

    const smsMessage = `Your SJVN Lunchify password reset OTP is ${otp}. Valid for 5 minutes. Please do not share this with anyone.`;
    await sendSMS(phone, smsMessage);

    res.json({ success: true, message: 'Reset OTP sent successfully' });
  } catch (err) {
    console.error('❌ forgot-password error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   7️⃣ RESET PASSWORD (VERIFY OTP & UPDATE PASSWORD)
--------------------------------------------------- */
router.post('/reset-password', async (req, res) => {
  try {
    const { employeeId, phone, otp, newPassword } = req.body;
    if (!employeeId || !phone || !otp || !newPassword) {
      return res.status(400).json({ message: 'All fields are required' });
    }
    const formattedId = employeeId.trim().toUpperCase();

    const [rows] = await mysqlPool.query(
      `SELECT * FROM otp_verifications
       WHERE phone_number = ? AND otp_code = ?
       ORDER BY created_at DESC LIMIT 1`,
      [phone, otp]
    );

    if (rows.length === 0) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    if (new Date(rows[0].expires_at) < new Date()) {
      return res.status(400).json({ message: 'OTP expired' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await mysqlPool.query(
      'UPDATE users SET password = ?, is_registered = 1 WHERE id = ?',
      [hashedPassword, formattedId]
    );

    res.json({ success: true, message: 'Password reset successfully' });
  } catch (err) {
    console.error('❌ reset-password error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

/* ---------------------------------------------------
   8️⃣ UPSERT USER / ROLE ASSIGNMENT (IT ADMIN ONLY)
--------------------------------------------------- */
const { requireAuth, requireITAdmin } = require('../middleware/auth.middleware');

router.post('/upsert-user', requireAuth, requireITAdmin, async (req, res) => {
  try {
    const { employeeId, admin_id, name, department, phone, password, role, project_id, canteen_id } = req.body;
    
    if (!employeeId || !name || !department || !phone || !role) {
      return res.status(400).json({ message: 'Employee ID, Name, Department, Phone, and Role are required' });
    }

    const formattedId = employeeId.trim().toUpperCase();
    const finalRoleId = role.trim();
    const finalProjectId = project_id || 1;
    const finalCanteenId = canteen_id || 1;
    const isAdmin = ['canteen_admin', 'hr_admin', 'it_admin'].includes(finalRoleId) ? 1 : 0;

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
        const hashedPassword = await bcrypt.hash(password, 10);
        query += `, password = ?`;
        params.push(hashedPassword);
      }

      query += ` WHERE id = ?`;
      params.push(formattedId);

      await mysqlPool.query(query, params);
      return res.json({ success: true, message: `User ${formattedId} updated successfully` });
    } else {
      // Insert new user
      if (!password || password.trim() === '') {
        return res.status(400).json({ message: 'Password is required for new users' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      await mysqlPool.query(
        `INSERT INTO users (id, name, department, phone, password, role, project_id, canteen_id, is_registered, is_admin, admin_id, is_active, coupons_left, monthly_limit)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, 1, 16, 16)`,
        [formattedId, name, department, phone, hashedPassword, finalRoleId, finalProjectId, finalCanteenId, isAdmin, admin_id || null]
      );

      return res.json({ success: true, message: `User ${formattedId} created successfully` });
    }
  } catch (err) {
    console.error('❌ upsert-user error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

