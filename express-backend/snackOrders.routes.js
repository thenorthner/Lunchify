const express = require('express');
const router = express.Router();
const db = require('../db');

// POST /api/snack-orders
router.post('/', async (req, res) => {
  const { employeeId, items } = req.body;

  if (!employeeId || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ message: 'Missing employeeId or items' });
  }

  try {
    const [orderResult] = await db.query(
      'INSERT INTO snack_orders (employee_id) VALUES (?)',
      [employeeId]
    );

    const orderId = orderResult.insertId;

    for (const item of items) {
      if (!item.name || item.cost === undefined || item.quantity === undefined) {
        return res.status(400).json({ message: 'Invalid item format' });
      }

      await db.query(
        'INSERT INTO snack_order_items (order_id, name, quantity, cost) VALUES (?, ?, ?, ?)',
        [orderId, item.name, item.quantity, item.cost]
      );
    }

    res.status(201).json({ message: 'Order placed', orderId });
  } catch (err) {
    console.error('❌ Error placing order:', err);
    res.status(500).json({ message: 'DB Error', error: err.message });
  }
});

module.exports = router;

