const express = require('express');
const router = express.Router();
// ✅ FIX: Destructure mysqlPool to match your db.js export
const { mysqlPool } = require('../db');
const { requireAuth } = require('../middleware/auth.middleware');

// ✅ POST share coupons with another employee
router.post('/share', requireAuth, async (req, res) => {
  const { receiverId, amount } = req.body;
  const senderId = req.user.id;

  const amt = Number(amount);
  if (!receiverId || !Number.isInteger(amt) || amt <= 0) {
    return res.status(400).json({ message: 'Invalid input parameters' });
  }

  if (!['employee', 'hr_admin', 'it_admin'].includes(req.user.role)) {
    return res.status(403).json({ message: 'Only employees or admins can share coupons' });
  }

  if (senderId === receiverId) {
    return res.status(400).json({ message: 'Cannot share coupons with yourself' });
  }

  let connection;
  try {
    connection = await mysqlPool.getConnection();
    await connection.beginTransaction();

    // Lock both users rows
    const [senderRows] = await connection.query('SELECT coupons_left, canteen_id FROM users WHERE id = ? FOR UPDATE', [senderId]);
    if (senderRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: 'Sender not found' });
    }
    
    if (senderRows[0].coupons_left < amt) {
      await connection.rollback();
      return res.status(400).json({ message: 'Insufficient coupons' });
    }

    const [receiverRows] = await connection.query('SELECT id, role, canteen_id, last_coupon_reset_month, monthly_limit FROM users WHERE id = ? FOR UPDATE', [receiverId]);
    if (receiverRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: 'Recipient employee not found' });
    }

    if (!['employee', 'hr_admin', 'it_admin'].includes(receiverRows[0].role)) {
      await connection.rollback();
      return res.status(400).json({ message: 'Coupons can only be shared with other employees or admins' });
    }

    if (senderRows[0].canteen_id !== receiverRows[0].canteen_id) {
      await connection.rollback();
      return res.status(400).json({ message: 'Coupons can only be shared within the same canteen' });
    }

    // Perform updates transactionally with WHERE check as an extra layer
    const [updateSender] = await connection.query(
      'UPDATE users SET coupons_left = coupons_left - ?, coupons_used = coupons_used + ? WHERE id = ? AND coupons_left >= ?', 
      [amt, amt, senderId, amt]
    );

    if (updateSender.affectedRows === 0) {
      await connection.rollback();
      return res.status(400).json({ message: 'Insufficient coupons' });
    }

    const receiver = receiverRows[0];
    const currentDate = new Date();
    const currentMonthStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}`;
    
    if (receiver.last_coupon_reset_month !== currentMonthStr) {
      // Lazy reset receiver's coupons first before adding shared amount
      await connection.query(
        'UPDATE users SET coupons_left = ?, coupons_used = 0, last_coupon_reset_month = ? WHERE id = ?',
        [receiver.monthly_limit + amt, currentMonthStr, receiverId]
      );
    } else {
      // Just add the shared amount
      await connection.query('UPDATE users SET coupons_left = coupons_left + ? WHERE id = ?', [amt, receiverId]);
    }

    // Log the share
    await connection.query('INSERT INTO coupon_shares (sender_id, receiver_id, amount) VALUES (?, ?, ?)', [senderId, receiverId, amt]);

    await connection.commit();
    res.json({ message: 'Coupons shared successfully', sharedAmount: amt });
  } catch (err) {
    if (connection) await connection.rollback();
    console.error('❌ Error sharing coupons:', err);
    res.status(500).json({ message: 'Internal Server Error' });
  } finally {
    if (connection) connection.release();
  }
});

// ✅ GET coupon info by employeeId
router.get('/:employeeId', requireAuth, async (req, res) => {
  const employeeId = req.params.employeeId?.trim().toUpperCase();

  if (!employeeId || !/^[A-Z0-9]{1,32}$/.test(employeeId)) {
    return res.status(400).json({ error: 'Invalid employee ID format' });
  }

  // BOLA check: standard employee can only read their own coupon balance
  if (req.user.role === 'employee' && req.user.id !== employeeId) {
    return res.status(403).json({ message: 'Access denied. You can only view your own coupons.' });
  }

  try {
    const [target] = await mysqlPool.query(
      'SELECT id, name, coupons_used AS couponsUsed, coupons_left AS couponsLeft, monthly_limit AS monthlyLimit, canteen_id, project_id FROM users WHERE TRIM(id) = ?', 
      [employeeId]
    );

    if (target.length === 0) {
      return res.status(404).json({ message: 'User not found in database' });
    }

    if (req.user.role === 'canteen_admin' && target[0].canteen_id !== req.user.canteen_id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (req.user.role === 'scanner' && target[0].canteen_id !== req.user.canteen_id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (req.user.role === 'hr_admin' && target[0].project_id !== req.user.project_id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (req.user.role === 'it_admin' && req.query.canteen_id && target[0].canteen_id !== Number(req.query.canteen_id)) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Return the first row found (filtering out the scoped columns so we don't leak them if we didn't before, though it's fine)
    const { name, couponsUsed, couponsLeft, monthlyLimit } = target[0];
    return res.json({ name, couponsUsed, couponsLeft, monthlyLimit });
  } catch (err) {
    console.error('❌ Error fetching coupon data:', err);
    return res.status(500).json({ message: 'Internal Server Error' });
  }
});

// ✅ GET combined coupon usage history
router.get('/history/:employeeId', requireAuth, async (req, res) => {
  try {
    const employeeId = req.params.employeeId?.trim().toUpperCase();

    if (!employeeId || !/^[A-Z0-9]{1,32}$/.test(employeeId)) {
      return res.status(400).json({ error: 'Invalid employee ID format' });
    }

    // BOLA check: standard employee can only read their own coupon history
    if (req.user.role === 'employee' && req.user.id !== employeeId) {
      return res.status(403).json({ message: 'Access denied. You can only view your own coupon history.' });
    }

    const [target] = await mysqlPool.query(
      'SELECT id, canteen_id, project_id FROM users WHERE id = ?', [employeeId]
    );
    if (target.length === 0) return res.status(404).json({ message: 'User not found' });

    if (req.user.role === 'canteen_admin' && target[0].canteen_id !== req.user.canteen_id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (req.user.role === 'scanner' && target[0].canteen_id !== req.user.canteen_id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (req.user.role === 'hr_admin' && target[0].project_id !== req.user.project_id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (req.user.role === 'it_admin' && req.query.canteen_id && target[0].canteen_id !== Number(req.query.canteen_id)) {
      return res.status(403).json({ message: 'Access denied' });
    }

    const monthStr = new Date().toLocaleDateString('en-CA').slice(0, 7); // YYYY-MM
    const query = `
      SELECT 'lunch' as usage_type, quantity as amount, DATE_FORMAT(DATE_ADD(created_at, INTERVAL '5:30' HOUR_MINUTE), '%Y-%m-%dT%T') as used_at, CONCAT('Pre-ordered Food: ', name) as description 
      FROM food_lunch_orders WHERE employee_id = ? AND created_at LIKE ?
      UNION ALL
      SELECT 'fruit' as usage_type, quantity as amount, DATE_FORMAT(DATE_ADD(created_at, INTERVAL '5:30' HOUR_MINUTE), '%Y-%m-%dT%T') as used_at, CONCAT('Pre-ordered Fruit: ', name) as description 
      FROM fruit_lunch_orders WHERE employee_id = ? AND created_at LIKE ?
      UNION ALL
      SELECT 'sharing' as usage_type, amount, DATE_FORMAT(DATE_ADD(shared_at, INTERVAL '5:30' HOUR_MINUTE), '%Y-%m-%dT%T') as used_at, CONCAT('Shared with: ', u.name) as description 
      FROM coupon_shares c JOIN users u ON c.receiver_id = u.id WHERE sender_id = ? AND shared_at LIKE ?
      UNION ALL
      SELECT 'received' as usage_type, amount, DATE_FORMAT(DATE_ADD(shared_at, INTERVAL '5:30' HOUR_MINUTE), '%Y-%m-%dT%T') as used_at, CONCAT('Received from: ', u.name) as description 
      FROM coupon_shares c JOIN users u ON c.sender_id = u.id WHERE receiver_id = ? AND shared_at LIKE ?
      UNION ALL
      SELECT 'lunch' as usage_type, 1 as amount, DATE_FORMAT(DATE_ADD(qsl.created_at, INTERVAL '5:30' HOUR_MINUTE), '%Y-%m-%dT%T') as used_at, CONCAT('QR Scan at Canteen: ', q.type) as description 
      FROM qr_scan_logs qsl 
      JOIN qr_codes q ON qsl.qr_id = q.id 
      WHERE q.employee_id = ? AND qsl.created_at LIKE ?
      ORDER BY used_at DESC
    `;
    
    const likeMonth = `${monthStr}%`;
    const [rows] = await mysqlPool.query(query, [employeeId, likeMonth, employeeId, likeMonth, employeeId, likeMonth, employeeId, likeMonth, employeeId, likeMonth]);
    res.json(rows);
  } catch (err) {
    console.error('❌ Error fetching coupon history:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;