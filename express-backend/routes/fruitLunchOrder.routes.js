const express = require('express');
const router = express.Router();
// ✅ FIX: Import mysqlPool from your db.js
const { mysqlPool } = require('../db'); 

// ✅ GET: summary of all fruit lunch orders
router.get('/', async (req, res) => {
  try {
    const [rows] = await mysqlPool.query(
      `SELECT o.employee_id, u.name, SUM(o.quantity) AS totalQuantity
       FROM fruit_lunch_orders o
       JOIN users u ON o.employee_id = u.id
       GROUP BY o.employee_id, u.name
       ORDER BY totalQuantity DESC`
    );
    res.json(rows);
  } catch (error) {
    console.error('❌ Error fetching fruit lunch orders:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// ✅ POST: Place a fruit lunch order (with Coupon deduction)
router.post('/order-fruit-lunch', async (req, res) => {
  const { employeeId, quantity, items } = req.body;

  // 1. Basic Validation
  if (!employeeId || !quantity) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  if (typeof quantity !== 'number' || quantity <= 0) {
    return res.status(400).json({ error: 'Quantity must be a positive number' });
  }

  try {
    // 2. Check User & Coupons
    const [userRows] = await mysqlPool.query(
      'SELECT coupons_left, coupons_used, name, canteen_id, project_id FROM users WHERE id = ?',
      [employeeId]
    );

    if (userRows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userRows[0];

    // Here quantity could be 1 for the whole lunch, regardless of how many items they pick
    if (user.coupons_left < quantity) {
      return res.status(400).json({ error: `Not enough coupons. You have ${user.coupons_left} left.` });
    }

    // 3. Prepare Date
    const today = new Date().toLocaleDateString('en-CA');

    // 4. Insert into fruit lunch orders
    await mysqlPool.query(
      `INSERT INTO fruit_lunch_orders 
        (employee_id, name, quantity, order_type, date, status, items, canteen_id, project_id, created_at) 
        VALUES (?, ?, ?, 'dineIn', ?, 'pending', ?, ?, ?, NOW())`,
      [
        employeeId,
        user.name,
        quantity,
        today,
        items ? JSON.stringify(items) : null,
        user.canteen_id,
        user.project_id
      ]
    );

    // 5. Deduct coupons from users table
    await mysqlPool.query(
      'UPDATE users SET coupons_left = coupons_left - ?, coupons_used = coupons_used + ? WHERE id = ?',
      [quantity, quantity, employeeId]
    );

    res.json({ success: true, message: `Fruit lunch ordered. ${quantity} coupons deducted.` });
  } catch (err) {
    console.error('❌ Error placing fruit lunch order:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// ✅ POST: Reset all fruit lunch orders
router.post('/reset', async (req, res) => {
  try {
    await mysqlPool.query('TRUNCATE TABLE fruit_lunch_orders');
    res.status(200).json({ message: 'Fruit lunch counts reset' });
  } catch (error) {
    console.error('❌ Error resetting fruit lunch counts:', error);
    res.status(500).json({ message: 'Reset failed' });
  }
});

module.exports = router;