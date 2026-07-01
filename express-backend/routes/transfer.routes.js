const express = require("express");
const router = express.Router();
const { mysqlPool } = require("../db");
const { requireAuth, requireHRAdmin, requireITAdmin } = require("../middleware/auth.middleware");
const { logAudit } = require('../utils/logger');

// Require authentication for all transfer routes
router.use(requireAuth);

/**
 * POST /api/transfer/request
 * Transfers an employee from their current project to a new target project.
 * Automatically aligns their canteen association, preserves current coupon balance, and logs the request.
 */
router.post("/request", requireHRAdmin, async (req, res) => {
  const { employee_id, to_project_id } = req.body;

  if (!employee_id || !to_project_id) {
    return res.status(400).json({ error: "Missing employee_id or to_project_id" });
  }

  const conn = await mysqlPool.getConnection();
  try {
    await conn.beginTransaction();

    // 1. Fetch user to verify they exist
    const [userRows] = await conn.query(
      "SELECT id, project_id, coupons_left, name FROM users WHERE id = ? FOR UPDATE",
      [employee_id]
    );

    if (userRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: "Employee not found" });
    }

    const employee = userRows[0];
    const from_project_id = employee.project_id;

    // Enforce HR project isolation: HR Admins can only transfer employees OUT OF their own project OR INTO their own project
    if (req.user.role === 'hr_admin' && from_project_id !== req.user.project_id && parseInt(to_project_id, 10) !== req.user.project_id) {
      await conn.rollback();
      return res.status(403).json({ error: "Access denied. You can only transfer employees to or from your assigned project." });
    }

    if (from_project_id === parseInt(to_project_id, 10)) {
      await conn.rollback();
      return res.status(400).json({ error: "Employee is already in the target project." });
    }

    // 2. Fetch the single canteen associated with the target project
    const [canteenRows] = await conn.query(
      "SELECT id FROM canteens WHERE project_id = ? AND is_active = 1 LIMIT 1",
      [to_project_id]
    );

    if (canteenRows.length === 0) {
      await conn.rollback();
      return res.status(400).json({ error: "Target project has no active canteen associated with it." });
    }

    const targetCanteenId = canteenRows[0].id;

    // 3. Update employee's project and canteen in users table
    await conn.query(
      "UPDATE users SET project_id = ?, canteen_id = ? WHERE id = ?",
      [to_project_id, targetCanteenId, employee_id]
    );

    // 4. Log transfer in transfer_requests
    await conn.query(
      `INSERT INTO transfer_requests 
       (employee_id, from_project_id, to_project_id, coupons_transferred, initiated_by) 
       VALUES (?, ?, ?, ?, ?)`,
      [employee_id, from_project_id, to_project_id, employee.coupons_left, req.user.id]
    );

    logAudit('TRANSFER_INITIATED', req.user.id, {
      employee_id,
      from_project_id,
      to_project_id,
      targetCanteenId,
      coupons_transferred: employee.coupons_left
    });

    await conn.commit();
    res.json({
      success: true,
      message: `Employee ${employee.name} (${employee_id}) successfully transferred to project ${to_project_id}. Canteen updated to ${targetCanteenId}.`,
      transferred_balance: employee.coupons_left
    });
  } catch (err) {
    await conn.rollback();
    console.error("❌ Error in transfer request:", err);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    conn.release();
  }
});

/**
 * GET /api/transfer/history
 * Gets transfer logs. HR Admin gets for their project, IT Admin gets all.
 */
router.get("/history", requireHRAdmin, async (req, res) => {
  let projectId = req.user.project_id;

  if (req.user.role === 'it_admin' && req.query.project_id) {
    projectId = req.query.project_id;
  }

  try {
    let query = `
      SELECT t.*, u.name as employee_name, p1.name as from_project, p2.name as to_project, admin.name as admin_name
      FROM transfer_requests t
      JOIN users u ON t.employee_id = u.id
      JOIN projects p1 ON t.from_project_id = p1.id
      JOIN projects p2 ON t.to_project_id = p2.id
      JOIN users admin ON t.initiated_by = admin.id
    `;
    const params = [];

    if (req.user.role === 'hr_admin' || (req.user.role === 'it_admin' && projectId)) {
      query += " WHERE t.from_project_id = ? OR t.to_project_id = ?";
      params.push(projectId, projectId);
    }

    query += " ORDER BY t.transferred_at DESC";

    const [rows] = await mysqlPool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("❌ Error getting transfer history:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * GET /api/transfer/projects
 * Retrieve a list of all active projects for the transfer dropdown
 */
router.get("/projects", requireAuth, async (req, res) => {
  try {
    const [rows] = await mysqlPool.query("SELECT id, name, location FROM projects ORDER BY name ASC");
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching projects:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /api/transfer/projects-canteens
// IT Admin retrieves all projects and their associated canteens, HR Admin retrieves for their project
router.get("/projects-canteens", requireAuth, async (req, res) => {
  if (!['it_admin', 'hr_admin'].includes(req.user.role)) {
    return res.status(403).json({ error: "Access denied" });
  }

  try {
    let query = `
      SELECT p.id as project_id, p.name as project_name, p.location as project_location, p.state as project_state,
             c.id as canteen_id, c.name as canteen_name, c.location as canteen_location, c.open_time, c.close_time
      FROM projects p
      LEFT JOIN canteens c ON c.project_id = p.id
    `;
    const params = [];
    if (req.user.role === 'hr_admin') {
      query += ` WHERE p.id = ?`;
      params.push(req.user.project_id);
    }
    query += ` ORDER BY p.id ASC`;

    const [rows] = await mysqlPool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching projects and canteens:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * POST /api/transfer/create-module
 * IT Admin creates a project and its mapped canteen in one transaction
 */
router.post("/create-module", requireITAdmin, async (req, res) => {
  const { project_name, state, canteen_name, location, open_time, close_time } = req.body;
  if (!project_name || !state || !canteen_name || !location) {
    return res.status(400).json({ error: "project_name, state, canteen_name, and location are required." });
  }

  const conn = await mysqlPool.getConnection();
  try {
    await conn.beginTransaction();

    const [projResult] = await conn.query(
      `INSERT INTO projects (name, location, state) VALUES (?, ?, ?)`,
      [project_name, location, state]
    );
    const projectId = projResult.insertId;

    await conn.query(
      `INSERT INTO canteens (project_id, name, location, open_time, close_time, is_active)
       VALUES (?, ?, ?, ?, ?, 1)`,
      [projectId, canteen_name, location, open_time || '07:00:00', close_time || '22:00:00']
    );

    await conn.commit();
    res.json({ success: true, message: "Project and Canteen created successfully!" });
  } catch (err) {
    await conn.rollback();
    console.error("❌ Error creating project/canteen module:", err);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    conn.release();
  }
});

/**
 * POST /api/transfer/canteens
 * IT Admin creates a new canteen
 */
router.post("/canteens", requireITAdmin, async (req, res) => {
  const { project_id, name, location, open_time, close_time } = req.body;
  if (!project_id || !name || !location) {
    return res.status(400).json({ error: "project_id, name, and location are required." });
  }
  
  try {
    await mysqlPool.query(
      `INSERT INTO canteens (project_id, name, location, open_time, close_time, is_active)
       VALUES (?, ?, ?, ?, ?, 1)`,
      [project_id, name, location, open_time || '07:00:00', close_time || '22:00:00']
    );
    res.json({ success: true, message: "Canteen created successfully" });
  } catch (err) {
    console.error("❌ Error creating canteen:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});
/**
 * DELETE /api/transfer/projects/:id
 * IT Admin deletes a project AND its canteen, mapping users to CHQ.
 */
router.delete("/projects/:id", requireITAdmin, async (req, res) => {
  const projectId = req.params.id;
  const CHQ_PROJECT_ID = Number(process.env.CHQ_PROJECT_ID);
  const CHQ_CANTEEN_ID = Number(process.env.CHQ_CANTEEN_ID);

  if (!CHQ_PROJECT_ID || !CHQ_CANTEEN_ID) {
    return res.status(500).json({ error: "System configuration error: CHQ fallback IDs not set." });
  }

  if (parseInt(projectId, 10) === CHQ_PROJECT_ID) {
    return res.status(400).json({ error: "Cannot delete the default CHQ Project." });
  }

  const conn = await mysqlPool.getConnection();
  try {
    await conn.beginTransaction();

    // Move users to CHQ
    await conn.query(
      "UPDATE users SET project_id = ?, canteen_id = ? WHERE project_id = ?",
      [CHQ_PROJECT_ID, CHQ_CANTEEN_ID, projectId]
    );

    // Get canteen id to delete if it exists
    const [canteenRows] = await conn.query("SELECT id FROM canteens WHERE project_id = ?", [projectId]);
    const canteenIdToDelete = canteenRows.length > 0 ? canteenRows[0].id : null;
    
    // Remap all foreign keys to CHQ
    const tablesWithCanteen = [
      'food_lunch_orders', 'fruit_lunch_orders', 'snack_orders', 
      'qr_scan_logs', 'feedbacks', 'daily_item_feedbacks', 
      'food_menu', 'fruit_menu', 'snacks_menu',
      'weekly_food_menu', 'weekly_fruit_menu', 'weekly_snacks_menu'
    ];
    for (const table of tablesWithCanteen) {
      try {
        await conn.query(`UPDATE ${table} SET canteen_id = ? WHERE canteen_id = ?`, [CHQ_CANTEEN_ID, canteenIdToDelete]);
      } catch (e) {} // Ignore if table doesn't have canteen_id
    }

    const tablesWithProject = [
      'food_lunch_orders', 'fruit_lunch_orders', 'snack_orders', 'monthly_bills'
    ];
    for (const table of tablesWithProject) {
      try {
        await conn.query(`UPDATE ${table} SET project_id = ? WHERE project_id = ?`, [CHQ_PROJECT_ID, projectId]);
      } catch (e) {}
    }

    try {
      await conn.query("UPDATE transfer_requests SET from_project_id = ? WHERE from_project_id = ?", [CHQ_PROJECT_ID, projectId]);
      await conn.query("UPDATE transfer_requests SET to_project_id = ? WHERE to_project_id = ?", [CHQ_PROJECT_ID, projectId]);
    } catch (e) {}

    // Delete canteen if exists
    if (canteenIdToDelete) {
      await conn.query("DELETE FROM canteens WHERE project_id = ?", [projectId]);
    }

    // Delete project
    const [delProj] = await conn.query("DELETE FROM projects WHERE id = ?", [projectId]);
    if (delProj.affectedRows === 0) {
      await conn.rollback();
      return res.status(404).json({ error: "Project not found." });
    }

    await conn.commit();
    
    // Audit log
    console.log(JSON.stringify({
      event: "PROJECT_DELETED",
      timestamp: new Date().toISOString(),
      actor_id: req.user.id,
      deleted_project_id: projectId,
      fallback_project_id: CHQ_PROJECT_ID
    }));

    res.json({ success: true, message: "Project and Canteen deleted successfully. Users moved to CHQ." });
  } catch (err) {
    await conn.rollback();
    console.error("❌ Error deleting project:", err);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    conn.release();
  }
});

module.exports = router;
