const express = require('express');
const router = express.Router();
const { mysqlPool } = require('../db'); 
const { requireAuth, requireCanteenAdmin } = require('../middleware/auth.middleware');

// Require authentication for all fruit lunch order endpoints
router.use(requireAuth);

// ✅ 1. POST: Create order with transaction-based coupon deduction
router.post('/order-fruit-lunch', async (req, res) => {
  const conn = await mysqlPool.getConnection();
  try {
    const employee_id = req.user.id;
    const { name, quantity, items, order_type, room_number, delivery_time } = req.body;

    if (!name || !quantity) {
      return res.status(400).json({ error: 'name and quantity are required' });
    }
    const qty = Number(quantity);
    if (!Number.isInteger(qty) || qty < 1 || qty > 16) {
      return res.status(400).json({ error: 'quantity must be an integer between 1 and 16' });
    }

    const today = new Date().toLocaleDateString('en-CA');

    await conn.beginTransaction();

    // Check if user has coupons left
    const [userRows] = await conn.query(
      "SELECT coupons_left FROM users WHERE id = ? FOR UPDATE",
      [employee_id]
    );

    if (userRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: 'Employee not found' });
    }

    const couponsLeft = userRows[0].coupons_left;
    if (couponsLeft < qty) {
      await conn.rollback();
      return res.status(400).json({ error: `Insufficient coupons. You have only ${couponsLeft} left.` });
    }

    // Insert order with status 'accepted' (auto-accepted like food orders)
    const itemsJson = items ? JSON.stringify(items) : null;
    const [result] = await conn.query(
      `INSERT INTO fruit_lunch_orders 
       (employee_id, name, quantity, order_type, room_number, delivery_time, date, status, canteen_id, project_id, items, created_at) 
       VALUES (?, ?, ?, ?, ?, ?, ?, 'accepted', ?, ?, ?, NOW())`,
      [employee_id, name, qty, order_type || null, room_number || null, delivery_time || null, today, req.user.canteen_id, req.user.project_id, itemsJson]
    );

    // Deduct coupons immediately
    await conn.query(
      "UPDATE users SET coupons_left = coupons_left - ?, coupons_used = coupons_used + ? WHERE id = ?",
      [qty, qty, employee_id]
    );

    await conn.commit();
    res.status(201).json({ success: true, orderId: result.insertId });
  } catch (err) {
    await conn.rollback();
    console.error('❌ Error creating fruit lunch order:', err);
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    conn.release();
  }
});

// ✅ GET: admin/details -> all fruit lunch orders for their canteen
router.get('/details', requireCanteenAdmin, async (req, res) => {
  try {
    let query = `
      SELECT o.id, o.employee_id, u.name AS employee_name, o.name AS item_name, o.quantity, o.order_type, o.room_number, 
             TIME_FORMAT(o.delivery_time, '%H:%i') AS delivery_time, o.date, o.created_at, o.status
      FROM fruit_lunch_orders o
      LEFT JOIN users u ON o.employee_id = u.id
    `;
    const params = [];

    if (req.user.role === 'canteen_admin' || req.user.role === 'scanner') {
      query += ' WHERE o.canteen_id = ?';
      params.push(req.user.canteen_id);
    } else if (req.user.role === 'it_admin') {
      if (!req.query.canteen_id) {
        return res.status(400).json({ error: 'canteen_id is required' });
      }
      query += ' WHERE o.canteen_id = ?';
      params.push(req.query.canteen_id);
    } else {
      return res.status(403).json({ error: 'Access denied' });
    }

    query += " ORDER BY o.created_at DESC LIMIT 1000";

    const [rows] = await mysqlPool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error('❌ Error fetching fruit lunch details:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ 2. GET: admin -> pending requests for TODAY (canteen isolated)
router.get('/requests', requireCanteenAdmin, async (req, res) => {
  try {
    const today = new Date().toLocaleDateString('en-CA');
    const [rows] = await mysqlPool.query(
      `SELECT o.id, o.employee_id, u.name AS employee_name, o.name AS item_name, o.quantity, o.order_type, o.room_number, 
              TIME_FORMAT(o.delivery_time, '%H:%i') AS delivery_time, o.date, o.created_at, o.status
       FROM fruit_lunch_orders o
       LEFT JOIN users u ON o.employee_id = u.id
       WHERE o.date = ? AND o.status = 'pending' AND o.canteen_id = ?
       ORDER BY o.created_at ASC LIMIT 1000`,
      [today, req.user.canteen_id]
    );
    res.json(rows);
  } catch (err) {
    console.error('❌ Error fetching fruit lunch requests:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ 3. PATCH: admin -> update status (accept / reject / cancel) with automatic refund
router.patch('/:id/status', requireCanteenAdmin, async (req, res) => {
  const conn = await mysqlPool.getConnection();
  try {
    const orderId = req.params.id;
    const { status } = req.body; 

    if (!['accepted', 'rejected', 'cancelled'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    await conn.beginTransaction();

    const [rows] = await conn.query(
      'SELECT employee_id, quantity, status FROM fruit_lunch_orders WHERE id = ? AND canteen_id = ? FOR UPDATE', 
      [orderId, req.user.canteen_id]
    );

    if (rows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: 'Order not found in your canteen' });
    }

    const order = rows[0];
    const prevStatus = order.status;

    // Refund coupons if rejecting/cancelling (and it wasn't already cancelled/rejected)
    if (['rejected', 'cancelled'].includes(status) && !['rejected', 'cancelled'].includes(prevStatus)) {
      await conn.query(
        "UPDATE users SET coupons_left = coupons_left + ?, coupons_used = coupons_used - ? WHERE id = ?",
        [order.quantity, order.quantity, order.employee_id]
      );
    }

    await conn.query('UPDATE fruit_lunch_orders SET status = ? WHERE id = ?', [status, orderId]);

    await conn.commit();
    res.json({ success: true, message: `Order status updated to ${status}` });
  } catch (err) {
    await conn.rollback();
    console.error('❌ Error updating fruit lunch status:', err);
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    conn.release();
  }
});

// ✅ PATCH: employee -> self-cancel order (Only if pending!)
router.patch('/:id/employee-cancel', async (req, res) => {
  const conn = await mysqlPool.getConnection();
  try {
    const orderId = req.params.id;
    const employee_id = req.user.id;

    await conn.beginTransaction();

    const [rows] = await conn.query(
      'SELECT id, employee_id, quantity, status FROM fruit_lunch_orders WHERE id = ? FOR UPDATE', 
      [orderId]
    );

    if (rows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: 'Order not found' });
    }

    const order = rows[0];

    if (order.employee_id !== employee_id) {
      await conn.rollback();
      return res.status(403).json({ error: 'Access denied. This is not your order.' });
    }

    if (order.status !== 'pending' && order.status !== 'accepted') {
      await conn.rollback();
      return res.status(400).json({ error: `Cannot cancel order at this stage. Current status is: ${order.status}` });
    }

    // Cancel order and refund coupons
    await conn.query("UPDATE fruit_lunch_orders SET status = 'cancelled' WHERE id = ?", [orderId]);
    
    await conn.query(
      "UPDATE users SET coupons_left = coupons_left + ?, coupons_used = coupons_used - ? WHERE id = ?",
      [order.quantity, order.quantity, employee_id]
    );

    await conn.commit();
    res.json({ success: true, message: 'Order cancelled successfully.' });
  } catch (err) {
    await conn.rollback();
    console.error('❌ Error in employee cancellation:', err);
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    conn.release();
  }
});

// ✅ 4. POST: user marks delivered
router.post('/:id/mark-delivered', async (req, res) => {
  try {
    const orderId = req.params.id;

    const [rows] = await mysqlPool.query('SELECT status, employee_id, canteen_id FROM fruit_lunch_orders WHERE id = ?', [orderId]);
    if (rows.length === 0) return res.status(404).json({ error: 'Order not found' });

    const order = rows[0];

    // Ensure only the owner, the correct canteen admin, scanner, or it admin can mark delivered
    if (order.employee_id !== req.user.id) {
      if ((req.user.role === 'canteen_admin' || req.user.role === 'scanner') && order.canteen_id !== req.user.canteen_id) {
        return res.status(403).json({ error: 'Access denied: wrong canteen' });
      }
      if (req.user.role !== 'canteen_admin' && req.user.role !== 'it_admin' && req.user.role !== 'scanner') {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    const current = rows[0].status;
    if (current !== 'accepted') {
      return res.status(400).json({ error: `Order must be accepted before marking delivered. Current: ${current}` });
    }

    await mysqlPool.query('UPDATE fruit_lunch_orders SET status = ?, delivered_at = NOW() WHERE id = ?', ['delivered', orderId]);
    return res.json({ success: true, message: 'Order marked as delivered' });
  } catch (err) {
    console.error('❌ Error marking fruit delivered:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ 5. GET: user -> check status
router.get('/status', async (req, res) => {
  try {
    const employeeId = req.user.id;
    const today = new Date().toLocaleDateString('en-CA');
    const [rows] = await mysqlPool.query(
      `SELECT id, quantity, order_type, room_number, TIME_FORMAT(delivery_time, '%H:%i') AS delivery_time, status
       FROM fruit_lunch_orders
       WHERE employee_id = ? AND date = ?
       ORDER BY created_at DESC
       LIMIT 1`, [employeeId, today]
    );

    return res.json({ order: rows[0] || null });
  } catch (err) {
    console.error('❌ Error fetching fruit status:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;