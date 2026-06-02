const express = require('express');
const router = express.Router();
// ✅ FIX: Destructure mysqlPool to match your db.js export
const { mysqlPool } = require('../db');

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