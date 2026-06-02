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

  try {
    const qrId = uuidv4();
    const qrData = `QR_${qrId}|${employeeId}|${type}|${date}`;

    await mysqlPool.query(
      `INSERT INTO qr_codes (id, type, used, items) VALUES (?, ?, 0, ?)`,
      [qrId, type, items ? JSON.stringify(items) : null]
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
    const employeeId = parts[1];
    const type = parts[2];
    const qrDate = parts[3];

    const today = new Date().toLocaleDateString('en-CA');
    if (qrDate !== today) {
      return res.status(400).json({
        success: false,
        message: 'QR is expired or not for today',
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
        SELECT DATE_FORMAT(created_at, '%Y-%m-%d') as label, COUNT(*) as count 
        FROM qr_scan_logs 
        WHERE canteen_id = ? 
        GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d') 
        ORDER BY label DESC 
        LIMIT 30`;
    } else if (selectedRange === 'monthly') {
      query = `
        SELECT DATE_FORMAT(created_at, '%Y-%m') as label, COUNT(*) as count 
        FROM qr_scan_logs 
        WHERE canteen_id = ? 
        GROUP BY DATE_FORMAT(created_at, '%Y-%m') 
        ORDER BY label DESC`;
    } else if (selectedRange === 'yearly') {
      query = `
        SELECT DATE_FORMAT(created_at, '%Y') as label, COUNT(*) as count 
        FROM qr_scan_logs 
        WHERE canteen_id = ? 
        GROUP BY DATE_FORMAT(created_at, '%Y') 
        ORDER BY label DESC`;
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

module.exports = router;