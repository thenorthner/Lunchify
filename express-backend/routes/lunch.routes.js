const express = require('express');
const router = express.Router();
const db = require('../db');
const authenticateToken = require('../middleware/authenticate');

// ✅ Protected Scan Endpoint
router.post('/scan', authenticateToken, async (req, res) => {
  const { employeeId } = req.body;

  if (!employeeId) {
    return res.status(400).json({ success: false, message: 'Employee ID is required' });
  }

  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE id = ? LIMIT 1',
      [employeeId.trim().toUpperCase()]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Employee not found' });
    }

    const user = rows[0];

    await db.query(
      'INSERT INTO lunch_logs (employee_id, scan_time) VALUES (?, NOW())',
      [user.id]
    );

    return res.json({
      success: true,
      message: '✅ Lunch scan recorded',
      user: {
        id: user.id,
        name: user.name,
        department: user.department,
      },
    });
  } catch (err) {
    console.error("❌ Scan error:", err);
    return res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
});

module.exports = router;
