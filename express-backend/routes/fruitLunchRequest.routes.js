const express = require('express');
const router = express.Router();
// ✅ FIX: Import mysqlPool correctly to match your db.js
const { mysqlPool } = require('../db');

// GET /api/fruit-lunch-requests
router.get('/', async (req, res) => {
  try {
    // ✅ FIX: Get local date to filter for TODAY only
    const today = new Date().toLocaleDateString('en-CA'); // YYYY-MM-DD

    // ✅ FIX: Use mysqlPool instead of db
    const [rows] = await mysqlPool.query(
      `SELECT
        f.employee_id AS employeeId,
        u.name,
        u.department AS room,
        f.quantity,
        f.status,
        TIME_FORMAT(f.created_at, '%H:%i') AS orderTime
       FROM fruit_lunch_orders f
       JOIN users u ON f.employee_id = u.id
       WHERE f.date = ?
       ORDER BY f.created_at DESC`,
      [today]
    );

    res.json(rows);
  } catch (error) {
    console.error('❌ Error fetching fruit lunch requests:', error);
    res.status(500).json({ message: 'Internal server error', details: error.message });
  }
});

module.exports = router;