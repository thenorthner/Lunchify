const express = require('express');
const router = express.Router();
const { mysqlPool } = require('../db');
const { requireAuth, requireITAdmin } = require('../middleware/auth.middleware');

router.use(requireAuth);

router.get('/canteen/:id', requireITAdmin, async (req, res) => {
  const canteenId = req.params.id;
  try {
    // 1. Canteen and Project details
    const [canteenRows] = await mysqlPool.query(`
      SELECT c.*, p.name AS project_name, p.state AS project_state, p.location AS project_location 
      FROM canteens c
      LEFT JOIN projects p ON c.project_id = p.id
      WHERE c.id = ?
    `, [canteenId]);

    if (canteenRows.length === 0) {
      return res.status(404).json({ error: 'Canteen not found' });
    }
    const canteen = canteenRows[0];

    // 2. Personnel
    const [personnelRows] = await mysqlPool.query(`
      SELECT id, name, department, designation, role, email, phone, location, is_active
      FROM users
      WHERE canteen_id = ?
      ORDER BY 
        CASE role 
          WHEN 'canteen_admin' THEN 1
          WHEN 'hr_admin' THEN 2
          ELSE 3
        END, name ASC
    `, [canteenId]);

    // 3. Menus (Food) - fetch latest week
    const [foodMenuRows] = await mysqlPool.query(`
      SELECT day_of_week, items FROM weekly_food_menu WHERE canteen_id = ? ORDER BY day_of_week ASC
    `, [canteenId]);

    // 4. Menus (Fruit)
    const [fruitMenuRows] = await mysqlPool.query(`
      SELECT day_of_week, fruits FROM weekly_fruit_menu WHERE canteen_id = ? ORDER BY day_of_week ASC
    `, [canteenId]);

    // 5. Menus (Snacks)
    const [snacksMenuRows] = await mysqlPool.query(`
      SELECT day_of_week, session, items FROM weekly_snacks_menu WHERE canteen_id = ? ORDER BY day_of_week ASC, session ASC
    `, [canteenId]);

    res.json({
      canteen,
      personnel: personnelRows,
      menus: {
        food: foodMenuRows,
        fruit: fruitMenuRows,
        snacks: snacksMenuRows
      }
    });

  } catch (err) {
    console.error('❌ Error inspecting canteen:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
