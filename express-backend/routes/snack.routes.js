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

    if (req.query.employeeId && req.query.employeeId === String(req.user.id)) {
      conditions.push("o.employee_id = ?");
      params.push(req.user.id);
    } else if (req.user.role === 'employee') {
      conditions.push("o.employee_id = ?");
      params.push(req.user.id);
    } else if (req.user.role === 'canteen_admin' || req.user.role === 'scanner') {
      conditions.push("o.canteen_id = ?");
      params.push(req.user.canteen_id);
    } else if (req.user.role === 'hr_admin') {
      conditions.push("o.project_id = ?");
      params.push(req.user.project_id);
    } else if (req.user.role === 'it_admin') {
      if (!req.query.canteen_id) {
        return res.status(400).json({ error: 'canteen_id is required for it_admin viewing all orders' });
      }
      conditions.push("o.canteen_id = ?");
      params.push(req.query.canteen_id);
    } else {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (req.query.employeeId && req.query.employeeId !== String(req.user.id) && req.user.role !== 'employee') {
      conditions.push("o.employee_id = ?");
      params.push(req.query.employeeId);
    }

    if (conditions.length > 0) {
      query += " WHERE " + conditions.join(" AND ");
    }

    query += " ORDER BY o.created_at DESC LIMIT 1000";

    const [rows] = await mysqlPool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching snack orders:", err);
    res.status(500).json({ success: false, error: "Internal Server Error" });
  }
});

// ✅ Create a new snack order (pay-at-counter model)
router.post('/', async (req, res) => {
  const { items, total_amount, total, employeeId, roomId, session } = req.body;
  const employee_id = employeeId || req.user.id;

  // BOLA check: standard employee can only place snack orders for themselves
  if (req.user.role === 'employee' && employee_id !== req.user.id) {
    return res.status(403).json({ error: "Access denied. You can only place snack orders for yourself." });
  }

  function computeSnackTotal(itemsStr) {
    const parsed = typeof itemsStr === 'string' ? JSON.parse(itemsStr) : itemsStr;
    if (!Array.isArray(parsed)) throw new Error('Invalid items format');

    return parsed.reduce((sum, item) => {
      const catalogItem = SNACKS_CATALOG.find(s => s.name === item.name);
      if (!catalogItem) throw new Error(`Unknown item: ${item.name}`);
      const qty = Number(item.qty ?? item.quantity ?? 1);
      if (!Number.isInteger(qty) || qty < 1) throw new Error('Invalid quantity');
      return sum + catalogItem.cost * qty;
    }, 0);
  }

  let finalTotal;
  try {
    finalTotal = computeSnackTotal(items);
  } catch (err) {
    console.error('Error adding snack limit:', err);
    return res.status(400).json({ error: 'Internal server error' });
  }

  const sessionVal = session || "morning";
  const canteen_id = req.user.canteen_id;
  const project_id = req.user.project_id;

  if (!items) {
    return res.status(400).json({ error: "Missing items" });
  }

  // Type Validation (Issue #5)
  if (typeof employee_id !== 'string') {
    return res.status(400).json({ error: "Invalid employeeId type" });
  }
  if (!Array.isArray(items) && typeof items !== 'string') {
    return res.status(400).json({ error: "Items must be an array or JSON string" });
  }
  if (typeof finalTotal !== 'number' || finalTotal < 0) {
    return res.status(400).json({ error: "Total must be a non-negative number" });
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
       VALUES (?, ?, ?, ?, ?, 'accepted', ?, ?, NOW())`,
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
    res.status(500).json({ success: false, error: "Internal Server Error" });
  }
});

// ✅ Update snack order status (accessible to canteen admins or order owner employee)
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  if (!status) {
    return res.status(400).json({ error: "Missing status field" });
  }

  // Enum Validation (Issue #4)
  const VALID_STATUSES = ['pending', 'accepted', 'rejected', 'delivered', 'cancelled'];
  if (!VALID_STATUSES.includes(status)) {
    return res.status(400).json({ error: "Invalid status" });
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
    } else if (!['canteen_admin', 'scanner'].includes(req.user.role)) {
      return res.status(403).json({ error: "Access denied." });
    }

    let updateQuery = "UPDATE snack_orders SET status = ? WHERE id = ?";
    const updateParams = [status, id];

    if (req.user.role === 'canteen_admin' || req.user.role === 'scanner') {
      updateQuery += " AND canteen_id = ?";
      updateParams.push(req.user.canteen_id);
    }

    const [result] = await mysqlPool.query(updateQuery, updateParams);
    
    if (result.affectedRows === 0 && req.user.role !== 'employee') {
       return res.status(404).json({ error: "Order not found in your canteen" });
    }

    res.json({ success: true });
  } catch (err) {
    console.error("❌ Error updating snack order:", err);
    res.status(500).json({ success: false, error: "Internal Server Error" });
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
    res.status(500).json({ success: false, error: "Internal Server Error" });
  }
});

module.exports = router;