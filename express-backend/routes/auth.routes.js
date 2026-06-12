const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { db } = require("../db");

console.log("✅ auth.routes.js loaded");

/* =====================================================
   🔐 ADMIN AUTH MIDDLEWARE
===================================================== */
const adminOnly = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "No token provided" });
  }

  try {
    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    if (decoded.is_admin !== 1) {
      return res.status(403).json({ message: "Admin access only" });
    }

    req.admin = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
};

/* =====================================================
   👤 EMPLOYEE LOGIN (APP / OTP FLOW)
===================================================== */
router.post("/login", async (req, res) => {
  try {
    const { employeeId, password } = req.body;

    if (!employeeId || !password) {
      return res.status(400).json({ message: "Missing credentials" });
    }

    const [rows] = await db.query(
      `SELECT id, name, password, is_admin, is_registered, role
       FROM users
       WHERE id = ? AND is_active = 1`,
      [employeeId.trim()]
    );

    if (!rows.length) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const user = rows[0];

    if (user.is_registered !== 1) {
      return res.status(403).json({ message: "User not registered" });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user.id, is_admin: user.is_admin },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.json({
      token,
      token_type: "Bearer",
      user: {
        id: user.id,
        name: user.name,
        is_admin: user.is_admin,
        role: user.role,
      },
    });
  } catch (err) {
    console.error("❌ login error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

/* =====================================================
   🛡️ ADMIN LOGIN (WEBSITE)
===================================================== */
router.post("/admin/login", async (req, res) => {
  try {
    const { employeeId, password } = req.body;

    if (!employeeId || !password) {
      return res.status(400).json({ message: "Missing credentials" });
    }

    const [rows] = await db.query(
      `SELECT id, name, password, is_admin, role
       FROM users
       WHERE id = ? AND is_active = 1`,
      [employeeId.trim()]
    );

    if (!rows.length) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const admin = rows[0];

    if (admin.is_admin !== 1) {
      return res.status(403).json({ message: "Not an admin" });
    }

    const match = await bcrypt.compare(password, admin.password);
    if (!match) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: admin.id, is_admin: 1 },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.json({
      token,
      admin: {
        id: admin.id,
        name: admin.name,
        role: admin.role,
      },
    });
  } catch (err) {
    console.error("❌ admin login error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
