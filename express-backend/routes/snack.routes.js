const express = require('express');
const router = express.Router();
const { mysqlPool } = require('../db');
const { requireAuth, requireCanteenAdmin } = require('../middleware/auth.middleware');

// Require authentication for all snack endpoints
router.use(requireAuth);

const SNACKS_CATALOG = [
  { name: "Samosa", emoji: "🥟", cost: 15 },
  { name: "Kachori", emoji: "🥯", cost: 15 },
  { name: "Tea (Chai)", emoji: "☕", cost: 10 },
  { name: "Coffee", emoji: "☕", cost: 15 },
  { name: "Bread Pakoda", emoji: "🍞", cost: 20 },
  { name: "Paneer Pakoda", emoji: "🧀", cost: 25 },
  { name: "Muffin", emoji: "🧁", cost: 30 },
  { name: "Sandwich", emoji: "🥪", cost: 35 },
  { name: "Cold Drink", emoji: "🥤", cost: 20 },
  { name: "Biscuits", emoji: "🍪", cost: 10 }
];

// ✅ GET active snacks catalog for setup / dropdown check
router.get('/active', async (req, res) => {
  res.json(SNACKS_CATALOG);
});

// ✅ Get all snack orders for this canteen (with joined employee name)
router.get('/', async (req, res) => {
  try {
    let query = `
      SELECT o.id, o.employee_id, u.name, o.room, o.session, o.items, o.total, o.status, o.created_at 
      FROM snack_orders o
      LEFT JOIN users u ON o.employee_id = u.id
    `;
    const params = [];
    const conditions = [];

    if (req.user.role === 'employee') {
      conditions.push("o.employee_id = ?");
      params.push(req.user.id);
    } else if (req.user.role === 'canteen_admin') {
      conditions.push("o.canteen_id = ?");
      params.push(req.user.canteen_id);
    } else if (req.user.role === 'it_admin' && req.query.canteen_id) {
      conditions.push("o.canteen_id = ?");
      params.push(req.query.canteen_id);
    }

    if (req.query.employeeId && req.user.role !== 'employee') {
      conditions.push("o.employee_id = ?");
      params.push(req.query.employeeId);
    }

    if (conditions.length > 0) {
      query += " WHERE " + conditions.join(" AND ");
    }

    query += " ORDER BY o.created_at DESC";

    const [rows] = await mysqlPool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching snack orders:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ✅ Create a new snack order (pay-at-counter model)
router.post('/', async (req, res) => {
  const { items, total_amount, total, employeeId, roomId, session } = req.body;
  const employee_id = employeeId || req.user.id;
  const finalTotal = total_amount !== undefined ? total_amount : total;
  const sessionVal = session || "morning";
  const canteen_id = req.user.canteen_id;
  const project_id = req.user.project_id;

  if (!items || finalTotal === undefined) {
    return res.status(400).json({ error: "Missing items or total" });
  }

  try {
    let roomVal = "Self-Pickup";
    if (roomId) {
      try {
        const [roomRows] = await mysqlPool.query("SELECT room_number FROM rooms WHERE id = ?", [roomId]);
        if (roomRows.length > 0) {
          roomVal = roomRows[0].room_number;
        }
      } catch (e) {
        console.error("Error resolving room:", e);
      }
    }

    const [result] = await mysqlPool.query(
      `INSERT INTO snack_orders (employee_id, room, session, items, total, status, canteen_id, project_id, created_at) 
       VALUES (?, ?, ?, ?, ?, 'pending', ?, ?, NOW())`,
      [
        employee_id,
        roomVal,
        sessionVal,
        typeof items === 'string' ? items : JSON.stringify(items),
        finalTotal,
        canteen_id,
        project_id
      ]
    );

    res.status(201).json({ success: true, orderId: result.insertId });
  } catch (err) {
    console.error("❌ Error placing snack order:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ✅ Update snack order status (accessible to canteen admins or order owner employee)
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  if (!status) {
    return res.status(400).json({ error: "Missing status field" });
  }

  try {
    if (req.user.role === 'employee') {
      const [orderRows] = await mysqlPool.query("SELECT employee_id FROM snack_orders WHERE id = ?", [id]);
      if (orderRows.length === 0 || orderRows[0].employee_id !== req.user.id) {
        return res.status(403).json({ error: "Unauthorized access to this order." });
      }
      if (status !== 'delivered') {
        return res.status(400).json({ error: "Employees are only permitted to complete their orders." });
      }
    }

    let updateQuery = "UPDATE snack_orders SET status = ? WHERE id = ?";
    const updateParams = [status, id];

    if (req.user.role === 'canteen_admin') {
      updateQuery += " AND canteen_id = ?";
      updateParams.push(req.user.canteen_id);
    }

    const [result] = await mysqlPool.query(updateQuery, updateParams);
    res.json({ success: true });
  } catch (err) {
    console.error("❌ Error updating snack order:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ✅ Delete a snack order
router.delete('/:id', requireCanteenAdmin, async (req, res) => {
  const { id } = req.params;
  try {
    await mysqlPool.query("DELETE FROM snack_orders WHERE id = ? AND canteen_id = ?", [id, req.user.canteen_id]);
    res.json({ success: true });
  } catch (err) {
    console.error("❌ Error deleting snack order:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;