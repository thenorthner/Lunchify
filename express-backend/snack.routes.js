const express = require('express');
const router = express.Router();
const db = require('../db');

// POST /api/snacks
router.post('/', async (req, res) => {
  const { name, cost } = req.body;

  if (!name || cost == null) {
    return res.status(400).json({ message: 'Missing name or cost' });
  }

  try {
    const [result] = await db.query('INSERT INTO snacks (name, cost) VALUES (?, ?)', [name, cost]);
    res.status(201).json({ message: 'Snack added', id: result.insertId });
  } catch (err) {
    console.error("❌ Error adding snack:", err);
    res.status(500).json({ message: 'DB Error', error: err.message });
  }
});

// GET /api/snacks
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM snacks');
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching snacks:", err);
    res.status(500).json({ message: 'DB Error', error: err.message });
  }
});

// DELETE /api/snacks/:id
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const [result] = await db.query('DELETE FROM snacks WHERE id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Snack not found' });
    }

    res.json({ message: 'Snack deleted successfully' });
  } catch (err) {
    console.error("❌ Error deleting snack:", err);
    res.status(500).json({ message: 'DB Error', error: err.message });
  }
});

module.exports = router;

