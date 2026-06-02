const express = require("express");
const router = express.Router();
const { mysqlPool } = require("../db");
const { requireAuth, requireCanteenAdmin } = require("../middleware/auth.middleware");

// Require authentication for all menu endpoints
router.use(requireAuth);

/* ================= FOOD MENU ================= */

router.post("/food", requireCanteenAdmin, async (req, res) => {
  const { menu_date, items } = req.body;
  const canteen_id = req.body.canteen_id || req.user.canteen_id;

  try {
    // Delete existing food menu for this date and canteen to prevent duplicates
    await mysqlPool.query(
      "DELETE FROM food_menu WHERE menu_date = ? AND canteen_id = ?",
      [menu_date, canteen_id]
    );

    await mysqlPool.query(
      "INSERT INTO food_menu (menu_date, items, canteen_id) VALUES (?, ?, ?)",
      [menu_date, JSON.stringify(items), canteen_id]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/food", async (req, res) => {
  const { date } = req.query;
  const canteen_id = req.query.canteen_id || req.user.canteen_id;

  try {
    // 1. Try daily override
    const [rows] = await mysqlPool.query(
      "SELECT items FROM food_menu WHERE menu_date = ? AND canteen_id = ?",
      [date, canteen_id]
    );

    if (rows.length && rows[0].items) {
      return res.json({ items: JSON.parse(rows[0].items) });
    }

    // 2. Fallback to weekly menu
    const dayOfWeek = new Date(date).getDay() || 7; // Sunday is 0 in JS, map it to 7
    const [weeklyRows] = await mysqlPool.query(
      "SELECT items FROM weekly_food_menu WHERE day_of_week = ? AND canteen_id = ?",
      [dayOfWeek, canteen_id]
    );

    if (weeklyRows.length && weeklyRows[0].items) {
      return res.json({ items: JSON.parse(weeklyRows[0].items) });
    }

    return res.json({ items: [] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ================= WEEKLY FOOD MENU ================= */
router.post("/weekly/food", requireCanteenAdmin, async (req, res) => {
  const { day_of_week, items } = req.body;
  const canteen_id = req.body.canteen_id || req.user.canteen_id;

  try {
    await mysqlPool.query(
      `INSERT INTO weekly_food_menu (day_of_week, items, canteen_id) 
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE items = VALUES(items)`,
      [day_of_week, JSON.stringify(items), canteen_id]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ================= FRUIT MENU ================= */

router.post("/fruit", requireCanteenAdmin, async (req, res) => {
  const { menu_date, fruits } = req.body;
  const canteen_id = req.body.canteen_id || req.user.canteen_id;

  try {
    // Delete existing fruit menu for this date and canteen to prevent duplicates
    await mysqlPool.query(
      "DELETE FROM fruit_menu WHERE menu_date = ? AND canteen_id = ?",
      [menu_date, canteen_id]
    );

    await mysqlPool.query(
      "INSERT INTO fruit_menu (menu_date, fruits, canteen_id) VALUES (?, ?, ?)",
      [menu_date, JSON.stringify(fruits), canteen_id]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/fruit", async (req, res) => {
  const { date } = req.query;
  const canteen_id = req.query.canteen_id || req.user.canteen_id;

  try {
    const [rows] = await mysqlPool.query(
      "SELECT fruits FROM fruit_menu WHERE menu_date = ? AND canteen_id = ?",
      [date, canteen_id]
    );

    if (rows.length && rows[0].fruits) {
      return res.json({ items: JSON.parse(rows[0].fruits) });
    }

    const dayOfWeek = new Date(date).getDay() || 7;
    const [weeklyRows] = await mysqlPool.query(
      "SELECT fruits FROM weekly_fruit_menu WHERE day_of_week = ? AND canteen_id = ?",
      [dayOfWeek, canteen_id]
    );

    if (weeklyRows.length && weeklyRows[0].fruits) {
      return res.json({ items: JSON.parse(weeklyRows[0].fruits) });
    }

    return res.json({ items: [] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ================= WEEKLY FRUIT MENU ================= */
router.post("/weekly/fruit", requireCanteenAdmin, async (req, res) => {
  const { day_of_week, fruits } = req.body;
  const canteen_id = req.body.canteen_id || req.user.canteen_id;

  try {
    await mysqlPool.query(
      `INSERT INTO weekly_fruit_menu (day_of_week, fruits, canteen_id) 
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE fruits = VALUES(fruits)`,
      [day_of_week, JSON.stringify(fruits), canteen_id]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ================= SNACKS MENU ================= */

router.post("/snacks", requireCanteenAdmin, async (req, res) => {
  const { menu_date, session, items } = req.body;
  const canteen_id = req.body.canteen_id || req.user.canteen_id;

  try {
    // Delete existing snack menu for this date, session and canteen to prevent duplicates
    await mysqlPool.query(
      "DELETE FROM snacks_menu WHERE menu_date = ? AND session = ? AND canteen_id = ?",
      [menu_date, session, canteen_id]
    );

    await mysqlPool.query(
      "INSERT INTO snacks_menu (menu_date, session, items, canteen_id) VALUES (?, ?, ?, ?)",
      [menu_date, session, JSON.stringify(items), canteen_id]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/snacks", async (req, res) => {
  const { date, session } = req.query;
  const canteen_id = req.query.canteen_id || req.user.canteen_id;

  try {
    if (date && session) {
      let itemNames = [];
      const [rows] = await mysqlPool.query(
        "SELECT items FROM snacks_menu WHERE menu_date = ? AND session = ? AND canteen_id = ?",
        [date, session, canteen_id]
      );

      if (rows.length && rows[0].items) {
        itemNames = JSON.parse(rows[0].items || "[]");
      } else {
        const dayOfWeek = new Date(date).getDay() || 7;
        const [weeklyRows] = await mysqlPool.query(
          "SELECT items FROM weekly_snacks_menu WHERE day_of_week = ? AND session = ? AND canteen_id = ?",
          [dayOfWeek, session, canteen_id]
        );
        if (weeklyRows.length && weeklyRows[0].items) {
          itemNames = JSON.parse(weeklyRows[0].items || "[]");
        }
      }

      if (!itemNames.length) {
        return res.json([]);
      }

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

      const detailedItems = itemNames.map(name => {
        const match = SNACKS_CATALOG.find(s => s.name === name);
        return match || { name, emoji: "🍴", cost: 15 };
      });

      return res.json(detailedItems);
    }

    const [rows] = await mysqlPool.query(
      "SELECT * FROM snacks_menu WHERE canteen_id = ? ORDER BY menu_date DESC",
      [canteen_id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ================= WEEKLY SNACKS MENU ================= */
router.post("/weekly/snacks", requireCanteenAdmin, async (req, res) => {
  const { day_of_week, session, items } = req.body;
  const canteen_id = req.body.canteen_id || req.user.canteen_id;

  try {
    await mysqlPool.query(
      `INSERT INTO weekly_snacks_menu (day_of_week, session, items, canteen_id) 
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE items = VALUES(items)`,
      [day_of_week, session, JSON.stringify(items), canteen_id]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ======= SNACKS BY TIME ======= */

router.get("/snacks-by-time", async (req, res) => {
  const { date, session } = req.query;
  const canteen_id = req.query.canteen_id || req.user.canteen_id;

  try {
    const [rows] = await mysqlPool.query(
      "SELECT items FROM snacks_menu WHERE menu_date = ? AND session = ? AND canteen_id = ?",
      [date, session, canteen_id]
    );

    if (rows.length && rows[0].items) {
      return res.json({ items: JSON.parse(rows[0].items) });
    }

    const dayOfWeek = new Date(date).getDay() || 7;
    const [weeklyRows] = await mysqlPool.query(
      "SELECT items FROM weekly_snacks_menu WHERE day_of_week = ? AND session = ? AND canteen_id = ?",
      [dayOfWeek, session, canteen_id]
    );
    
    if (weeklyRows.length && weeklyRows[0].items) {
      return res.json({ items: JSON.parse(weeklyRows[0].items) });
    }

    return res.json({ items: [] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
