// routes/qr.routes.js
const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const { mysqlPool } = require('../db');
const { requireAuth, requireCanteenAdmin } = require('../middleware/auth.middleware');

// Apply auth to all QR routes
router.use(requireAuth);

// ✅ GET /api/qr/test (Protected test route)
router.get('/test', (req, res) => {
  return res.status(200).json({
    success: true,
    message: 'QR routes are reachable and authenticated ✅',
  });
});

// ✅ POST /api/qr/generate-qr - Generates QR for employee
router.post('/generate-qr', async (req, res) => {
  const { employeeId, type, date, items } = req.body;

  if (!employeeId || !type || !date) {
    return res.status(400).json({
      success: false,
      message: 'Missing employeeId, type, or date',
    });
  }

  // BOLA check: standard employee can only generate QR for themselves
  if (req.user.role === 'employee' && req.user.id !== employeeId) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. You can only generate QR codes for yourself.',
    });
  }

  try {
    const qrId = uuidv4();
    const qrData = `QR_${qrId}|${employeeId}|${type}|${date}`;

    await mysqlPool.query(
      `INSERT INTO qr_codes (id, type, used, employee_id, items) VALUES (?, ?, 0, ?, ?)`,
      [qrId, type, employeeId, items ? JSON.stringify(items) : null]
    );

    return res.status(200).json({
      success: true,
      message: 'QR generated',
      qrData,
    });
  } catch (err) {
    console.error('QR Generation Error:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate QR',
    });
  }
});

// ✅ POST /api/qr/status - Checks if a generated QR code was scanned
router.post('/status', async (req, res) => {
  const { qrToken } = req.body;
  if (!qrToken) return res.status(400).json({ error: 'Missing qrToken' });

  try {
    // qrToken format: QR_1234abcd-56ef...|EMP123|Food Lunch|2023-10-25
    const parts = qrToken.split('|');
    const qrId = parts[0].replace('QR_', '');
    const embeddedEmpId = parts[1];

    // BOLA check: standard employee can only query their own QR status
    if (req.user.role === 'employee' && req.user.id !== embeddedEmpId) {
      return res.status(403).json({ error: 'Access denied. You can only view status of your own QR codes.' });
    }

    const [rows] = await mysqlPool.query('SELECT used FROM qr_codes WHERE id = ?', [qrId]);
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'QR not found' });
    }
    
    return res.json({ scanned: rows[0].used === 1 });
  } catch (err) {
    console.error('QR Status Check Error:', err);
    return res.status(500).json({ error: 'Failed to check status' });
  }
});

// ✅ POST /api/qr/cancel - Cancels an unscanned QR code
router.post('/cancel', async (req, res) => {
  const { qrToken } = req.body;
  if (!qrToken) return res.status(400).json({ error: 'Missing qrToken' });

  try {
    const parts = qrToken.split('|');
    const qrId = parts[0].replace('QR_', '');
    const embeddedEmpId = parts[1];

    // BOLA check: standard employee can only cancel their own QR
    if (req.user.role === 'employee' && req.user.id !== embeddedEmpId) {
      return res.status(403).json({ error: 'Access denied. You can only cancel your own QR codes.' });
    }

    // Only delete if it hasn't been used yet
    await mysqlPool.query('DELETE FROM qr_codes WHERE id = ? AND used = 0', [qrId]);
    return res.json({ success: true, message: 'QR canceled' });
  } catch (err) {
    console.error('QR Cancel Error:', err);
    return res.status(500).json({ error: 'Failed to cancel QR' });
  }
});

// ✅ POST /api/qr/scan - Scanned by Canteen Admin, records scan at their canteen
router.post('/scan', requireCanteenAdmin, async (req, res) => {
  const { qrData } = req.body;
  const scannerId = req.user.id;
  const canteenId = req.user.canteen_id;

  if (!qrData) {
    return res.status(400).json({
      success: false,
      message: 'Missing qrData',
    });
  }

  const conn = await mysqlPool.getConnection();
  try {
    const parts = qrData.split('|');
    if (parts.length !== 4) {
      return res.status(400).json({
        success: false,
        message: 'Invalid QR format',
      });
    }

    const qrId = parts[0].replace('QR_', '');
    const embeddedEmployeeId = parts[1];
    const type = parts[2];
    const qrDate = parts[3];

    // Enforce same-day expiry
    const today = new Date().toLocaleDateString('en-CA');
    if (qrDate !== today) {
      return res.status(400).json({
        success: false,
        message: 'QR expired. QR codes are only valid on the day they are generated.',
      });
    }
    await conn.beginTransaction();

    const [qrRows] = await conn.query(
      `SELECT * FROM qr_codes WHERE id = ? FOR UPDATE`,
      [qrId]
    );

    if (qrRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({
        success: false,
        message: 'QR not found',
      });
    }

    const qr = qrRows[0];
    if (qr.used) {
      await conn.rollback();
      return res.status(400).json({
        success: false,
        message: 'QR already used',
      });
    }

    // Verify token integrity: don't trust embedded employee ID
    const employeeId = qr.employee_id;
    if (embeddedEmployeeId !== employeeId) {
      await conn.rollback();
      return res.status(400).json({
        success: false,
        message: 'QR token integrity check failed',
      });
    }

    const [userRows] = await conn.query(
      `SELECT * FROM users WHERE id = ? FOR UPDATE`,
      [employeeId]
    );

    if (userRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const user = userRows[0];
    if (user.coupons_left <= 0) {
      await conn.rollback();
      return res.status(400).json({
        success: false,
        message: 'No coupons left on employee card',
      });
    }

    // Update QR code status
    await conn.query(
      `UPDATE qr_codes SET used = 1, used_by = ?, used_at = NOW() WHERE id = ?`,
      [scannerId, qrId]
    );

    // Deduct 1 coupon from user
    await conn.query(
      `UPDATE users SET coupons_left = coupons_left - 1, coupons_used = coupons_used + 1 WHERE id = ?`,
      [employeeId]
    );

    // Log the scan with the scanner's canteen ID
    await conn.query(
      `INSERT INTO qr_scan_logs (qr_id, scanned_by, lunch_type, canteen_id, items) VALUES (?, ?, ?, ?, ?)`,
      [qrId, scannerId, type, canteenId, qr.items ? JSON.stringify(qr.items) : null]
    );

    await conn.commit();
    return res.status(200).json({
      success: true,
      message: 'QR scanned successfully and coupon deducted.',
      employee: {
        id: user.id,
        name: user.name,
        department: user.department,
        coupons_left: user.coupons_left - 1
      },
      items: qr.items
    });
  } catch (err) {
    await conn.rollback();
    console.error('QR Scan Error:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to scan QR',
    });
  } finally {
    conn.release();
  }
});

// ✅ GET /api/qr/scan-logs - Returns scan logs for a canteen, with optional filters
router.get('/scan-logs', requireCanteenAdmin, async (req, res) => {
  try {
    let canteenId = req.user.canteen_id;
    if (req.user.role === 'it_admin' && req.query.canteen_id) {
      canteenId = req.query.canteen_id;
    }

    const { employee_id, date, month } = req.query;

    let query = `
      SELECT ql.id, ql.created_at, u.name as employee_name, u.id as employee_id, q.type, q.items
      FROM qr_scan_logs ql
      JOIN qr_codes q ON ql.qr_id = q.id
      JOIN users u ON q.employee_id = u.id
      WHERE ql.canteen_id = ?
    `;
    const queryParams = [canteenId];

    if (employee_id) {
      query += ` AND u.id = ?`;
      queryParams.push(employee_id);
    }

    if (date) {
      // date is expected in YYYY-MM-DD
      query += ` AND ql.created_at LIKE ?`;
      queryParams.push(`${date}%`);
    } else if (month) {
      // month is expected in YYYY-MM
      query += ` AND ql.created_at LIKE ?`;
      queryParams.push(`${month}%`);
    } else {
      // Default: Last 30 days
      query += ` AND ql.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)`;
    }

    query += ` ORDER BY ql.created_at DESC`;

    const [rows] = await mysqlPool.query(query, queryParams);
    res.json(rows);
  } catch (err) {
    console.error('Scan logs Error:', err);
    res.status(500).json({ error: 'Failed to fetch scan logs' });
  }
});

// ✅ GET /api/qr/scanned-history - Returns aggregated counts (Daily, Monthly, Yearly)
router.get('/scanned-history', requireCanteenAdmin, async (req, res) => {
  const { range } = req.query; // 'daily', 'monthly', 'yearly'
  const selectedRange = range || 'daily';
  let canteenId = req.user.canteen_id;

  // IT Admins can view other canteens
  if (req.user.role === 'it_admin' && req.query.canteen_id) {
    canteenId = req.query.canteen_id;
  }

  try {
    let query = '';
    const params = [canteenId];

    if (selectedRange === 'daily') {
      query = `
        SELECT label, SUM(count) as count FROM (
          SELECT DATE_FORMAT(created_at, '%Y-%m-%d') as label, COUNT(*) as count 
          FROM qr_scan_logs 
          WHERE canteen_id = ? 
          GROUP BY label 
          UNION ALL
          SELECT DATE_FORMAT(created_at, '%Y-%m-%d') as label, SUM(quantity) as count 
          FROM fruit_lunch_orders 
          WHERE canteen_id = ? 
          GROUP BY label
        ) t
        GROUP BY label
        ORDER BY label DESC 
        LIMIT 30`;
      params.push(canteenId);
    } else if (selectedRange === 'monthly') {
      query = `
        SELECT label, SUM(count) as count FROM (
          SELECT DATE_FORMAT(created_at, '%Y-%m') as label, COUNT(*) as count 
          FROM qr_scan_logs 
          WHERE canteen_id = ? 
          GROUP BY label 
          UNION ALL
          SELECT DATE_FORMAT(created_at, '%Y-%m') as label, SUM(quantity) as count 
          FROM fruit_lunch_orders 
          WHERE canteen_id = ? 
          GROUP BY label
        ) t
        GROUP BY label
        ORDER BY label DESC`;
      params.push(canteenId);
    } else if (selectedRange === 'yearly') {
      query = `
        SELECT label, SUM(count) as count FROM (
          SELECT DATE_FORMAT(created_at, '%Y') as label, COUNT(*) as count 
          FROM qr_scan_logs 
          WHERE canteen_id = ? 
          GROUP BY label 
          UNION ALL
          SELECT DATE_FORMAT(created_at, '%Y') as label, SUM(quantity) as count 
          FROM fruit_lunch_orders 
          WHERE canteen_id = ? 
          GROUP BY label
        ) t
        GROUP BY label
        ORDER BY label DESC`;
      params.push(canteenId);
    } else {
      return res.status(400).json({ error: 'Invalid range parameter. Use daily, monthly, or yearly.' });
    }

    const [rows] = await mysqlPool.query(query, params);
    res.json({
      success: true,
      range: selectedRange,
      data: rows
    });
  } catch (err) {
    console.error('❌ Error fetching scan history:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ GET /api/qr/my-status-today - Returns if employee has scanned food or fruit today
router.get('/my-status-today', async (req, res) => {
  const employeeId = req.user.id;
  try {
    const [rows] = await mysqlPool.query(
      `SELECT type FROM qr_codes WHERE employee_id = ? AND used = 1 AND DATE(used_at) = CURDATE()`,
      [employeeId]
    );
    let foodScanned = false;
    let fruitScanned = false;
    rows.forEach(r => {
      if (r.type === 'food') foodScanned = true;
      if (r.type === 'fruit') fruitScanned = true;
    });

    // Check fruit_lunch_orders for fruit lunch
    const [fruitRows] = await mysqlPool.query(
      `SELECT id FROM fruit_lunch_orders WHERE employee_id = ? AND DATE(created_at) = CURDATE() LIMIT 1`,
      [employeeId]
    );
    if (fruitRows.length > 0) {
      fruitScanned = true;
    }

    res.json({ success: true, foodScanned, fruitScanned });
  } catch (err) {
    console.error('❌ Error fetching today status:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;