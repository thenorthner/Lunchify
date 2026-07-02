const express = require('express');
const db = require('../db');
const router = express.Router();

/* ---------------- ADMIN LOGIN ---------------- */
router.post('/login', (req, res) => {
  const { username, password } = req.body;

  if (username === 'admin' && password === 'admin123') {
    return res.json({ token: 'admin-token' });
  }
  res.status(401).json({ message: 'Invalid login' });
});

/* ---------------- MENU CRUD ---------------- */
router.get('/menu/:type', (req, res) => {
  const table = `${req.params.type}_menu`;
  db.query(`SELECT * FROM ${table}`, (err, rows) => {
    if (err) return res.status(500).json(err);
    res.json(rows);
  });
});

router.post('/menu/:type', (req, res) => {
  const table = `${req.params.type}_menu`;
  const { name, price } = req.body;

  db.query(
    `INSERT INTO ${table} (name, price) VALUES (?, ?)`,
    [name, price],
    err => {
      if (err) return res.status(500).json(err);
      res.json({ message: 'Item added' });
    }
  );
});

/* ---------------- ORDERS ---------------- */
router.get('/orders', (req, res) => {
  db.query(`SELECT * FROM orders`, (err, rows) => {
    if (err) return res.status(500).json(err);
    res.json(rows);
  });
});

/* ---------------- BILL GENERATION ---------------- */
router.post('/bills/generate', (req, res) => {
  const { month, year } = req.body;

  db.query(
    `SELECT employee_id, SUM(total_amount) total
     FROM orders
     WHERE MONTH(order_date)=? AND YEAR(order_date)=?
     GROUP BY employee_id`,
    [month, year],
    (err, rows) => {
      if (err) return res.status(500).json(err);
      res.json(rows);
    }
  );
});

module.exports = router;
