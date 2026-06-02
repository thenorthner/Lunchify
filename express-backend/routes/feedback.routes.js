const express = require("express");
const router = express.Router();
const { mysqlPool } = require("../db");
const { requireAuth, requireITAdmin } = require("../middleware/auth.middleware");

// Require authentication for all feedback routes
router.use(requireAuth);

/**
 * POST /api/feedbacks
 * Employees or admins submit feedback/problem report about their canteen
 */
router.post("/", async (req, res) => {
  const { subject, message, rating } = req.body;
  const employeeId = req.user.id;
  const canteenId = req.user.canteen_id;

  if (!subject || !message) {
    return res.status(400).json({ error: "Subject and message are required" });
  }

  try {
    await mysqlPool.query(
      `INSERT INTO feedbacks (employee_id, canteen_id, subject, message, rating) 
       VALUES (?, ?, ?, ?, ?)`,
      [employeeId, canteenId, subject, message, rating || 5]
    );

    res.status(201).json({ success: true, message: "Feedback submitted successfully. Thank you!" });
  } catch (err) {
    console.error("❌ Error submitting feedback:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * GET /api/feedbacks
 * Only IT Admins can view the submitted feedbacks/problems logs
 */
router.get("/", requireITAdmin, async (req, res) => {
  try {
    const [rows] = await mysqlPool.query(
      `SELECT f.*, u.name as employee_name, u.department as employee_department, c.name as canteen_name, p.name as project_name
       FROM feedbacks f
       JOIN users u ON f.employee_id = u.id
       JOIN canteens c ON f.canteen_id = c.id
       JOIN projects p ON c.project_id = p.id
       ORDER BY f.created_at DESC`
    );

    res.json(rows);
  } catch (err) {
    console.error("❌ Error retrieving feedbacks:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
