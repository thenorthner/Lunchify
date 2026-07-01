const express = require("express");
const router = express.Router();
const { getDB } = require("../db");
const { requireAuth } = require("../middleware/auth.middleware");

// ✅ Get all active rooms (for dropdown)
router.get("/", requireAuth, async (req, res) => {
  try {
    const db = getDB();
    const [rooms] = await db.query(
      "SELECT id, room_number FROM rooms WHERE is_active = true ORDER BY room_number"
    );
    res.json(rooms);
  } catch (err) {
    console.error("❌ Error fetching rooms:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
