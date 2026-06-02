const express = require('express');
const router = express.Router();
// ✅ Use destructuring to match your db.js export
const { mysqlPool } = require('../db');

console.log("✅ fruitMenu.routes.js loaded");

// Simple test route
router.get('/test', (req, res) => {
  res.json({ message: '✅ GET fruit-menu working' });
});

// ✅ Example: Real route to get fruit menu from DB
router.get('/list', async (req, res) => {
  try {
    const today = new Date().toLocaleDateString('en-CA');
    const [rows] = await mysqlPool.query(
      'SELECT items FROM menu WHERE date = ? AND lunch_type = "fruit" LIMIT 1',
      [today]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'No fruit menu today' });
    }

    res.json({ success: true, items: JSON.parse(rows[0].items) });
  } catch (err) {
    console.error('❌ Error fetching fruit menu:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;