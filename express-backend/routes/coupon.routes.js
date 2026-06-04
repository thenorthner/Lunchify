const express = require('express');
const router = express.Router();
// ✅ FIX: Destructure mysqlPool to match your db.js export
const { mysqlPool } = require('../db');
const { requireAuth } = require('../middleware/auth.middleware');

// ✅ POST share coupons with another employee
router.post('/share', requireAuth, async (req, res) => {
  const { receiverId, amount } = req.body;
  const senderId = req.user.id;

  if (!receiverId || !amount || amount <= 0) {
    return res.status(400).json({ message: 'Invalid input parameters' });
  }

  if (senderId === receiverId) {
    return res.status(400).json({ message: 'Cannot share coupons with yourself' });
  }

  let connection;
  try {
    connection = await mysqlPool.getConnection();
    await connection.beginTransaction();

    // Lock both users rows
    const [senderRows] = await connection.query('SELECT coupons_left FROM users WHERE id = ? FOR UPDATE', [senderId]);
    if (senderRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: 'Sender not found' });
    }
    
    if (senderRows[0].coupons_left < amount) {
      await connection.rollback();
      return res.status(400).json({ message: 'Insufficient coupons' });
    }

    const [receiverRows] = await connection.query('SELECT id, role FROM users WHERE id = ? FOR UPDATE', [receiverId]);
    if (receiverRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: 'Recipient employee not found' });
    }

    if (receiverRows[0].role !== 'employee') {
      await connection.rollback();
      return res.status(400).json({ message: 'Coupons can only be shared with other employees' });
    }

    // Perform updates
    await connection.query('UPDATE users SET coupons_left = coupons_left - ? WHERE id = ?', [amount, senderId]);
    await connection.query('UPDATE users SET coupons_left = coupons_left + ? WHERE id = ?', [amount, receiverId]);

    await connection.commit();
    res.json({ message: 'Coupons shared successfully', sharedAmount: amount });
  } catch (err) {
    if (connection) await connection.rollback();
    console.error('❌ Error sharing coupons:', err);
    res.status(500).json({ message: 'Internal Server Error' });
  } finally {
    if (connection) connection.release();
  }
});

// ✅ GET coupon info by employeeId
router.get('/:employeeId', async (req, res) => {
  const employeeId = req.params.employeeId;

  try {
    // ✅ FIX: Use mysqlPool instead of db
    const [rows] = await mysqlPool.query(
      `SELECT name,
              coupons_used AS couponsUsed,
              coupons_left AS couponsLeft,
              monthly_limit AS monthlyLimit
       FROM users
       WHERE TRIM(id) = ?`,
      [employeeId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found in database' });
    }

    // Return the first row found
    return res.json(rows[0]);
  } catch (err) {
    console.error('❌ Error fetching coupon data:', err);
    return res.status(500).json({ message: 'Internal Server Error', error: err.message });
  }
});

module.exports = router;