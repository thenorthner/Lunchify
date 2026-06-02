const express = require("express");
const router = express.Router();
const { getDB } = require("../db");

// ✅ Get all active rooms (for dropdown)
router.get("/", async (req, res) => {
  const db = getDB();
  const [rooms] = await db.query(
    "SELECT id, room_number FROM rooms WHERE is_active = true ORDER BY room_number"
  );
  res.json(rooms);
});

module.exports = router;
