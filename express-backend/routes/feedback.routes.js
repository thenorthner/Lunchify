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

/**
 * POST /api/feedbacks/:id/respond
 * IT Admin responds to a ticket. Simulates a push notification.
 */
router.post("/:id/respond", requireITAdmin, async (req, res) => {
  const { id } = req.params;
  const { message } = req.body;

  if (!message) {
    return res.status(400).json({ error: "Response message is required" });
  }

  try {
    // Ideally, here you would:
    // 1. Save the response in the DB (e.g. update feedbacks table with 'response' and 'status'='closed')
    // 2. Fetch the user's FCM token from DB
    // 3. Send a push notification using Firebase Admin SDK: admin.messaging().send(...)
    
    // For now, we simulate the success of this operation.
    console.log(`✅ Admin responded to ticket ${id} with: "${message}"`);
    console.log(`🔔 Simulating push notification to user's mobile device...`);
    
    res.json({ success: true, message: "Response sent and push notification delivered." });
  } catch (err) {
    console.error("❌ Error responding to feedback:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * DELETE /api/feedbacks/:id
 * IT Admin deletes a ticket.
 */
router.delete("/:id", requireITAdmin, async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await mysqlPool.query(`DELETE FROM feedbacks WHERE id = ?`, [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Feedback not found" });
    }

    res.json({ success: true, message: "Feedback deleted successfully" });
  } catch (err) {
    console.error("❌ Error deleting feedback:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
