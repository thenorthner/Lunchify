const jwt = require("jsonwebtoken");
const { mysqlPool } = require("../db");

exports.requireAuth = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "No token provided" });
  }

  try {
    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 1. Single-Device Session Token Check & User Validation
    const [rows] = await mysqlPool.query(
      "SELECT id, role, project_id, canteen_id, session_token, last_coupon_reset_month, coupons_left FROM users WHERE id = ?",
      [decoded.id]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: "User not found" });
    }

    const dbUser = rows[0];

    // Check session token mismatch (signifies another device logged in)
    if (dbUser.session_token && decoded.sessionToken && dbUser.session_token !== decoded.sessionToken) {
      return res.status(401).json({ message: "Logged in from another device. Please login again." });
    }

    // 2. Automated Monthly 16 Coupon Reset Check
    const currentMonth = new Date().toLocaleDateString('en-CA').slice(0, 7); // 'YYYY-MM'
    if (dbUser.role === 'employee' && dbUser.last_coupon_reset_month !== currentMonth) {
      console.log(`⏳ Auto-resetting coupons for employee ${dbUser.id} for month ${currentMonth}`);
      await mysqlPool.query(
        "UPDATE users SET coupons_left = 16, coupons_used = 0, last_coupon_reset_month = ? WHERE id = ?",
        [currentMonth, dbUser.id]
      );
      dbUser.coupons_left = 16;
      dbUser.last_coupon_reset_month = currentMonth;
    }

    // Append standard user details to request
    req.user = {
      id: dbUser.id,
      role: dbUser.role,
      project_id: dbUser.project_id,
      canteen_id: dbUser.canteen_id,
      coupons_left: dbUser.coupons_left
    };

    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
};

// IT Admin check
exports.requireITAdmin = (req, res, next) => {
  if (req.user?.role !== "it_admin") {
    return res.status(403).json({ message: "Access denied. IT Admin role required." });
  }
  next();
};

// HR Admin check
exports.requireHRAdmin = (req, res, next) => {
  if (req.user?.role !== "hr_admin" && req.user?.role !== "it_admin") {
    return res.status(403).json({ message: "Access denied. HR Admin role required." });
  }
  next();
};

// Canteen Admin check
exports.requireCanteenAdmin = (req, res, next) => {
  if (req.user?.role !== "canteen_admin" && req.user?.role !== "it_admin") {
    return res.status(403).json({ message: "Access denied. Canteen Admin role required." });
  }
  next();
};

// Legacy support: requireAdmin mapped to Canteen Admin or above
exports.requireAdmin = (req, res, next) => {
  if (req.user?.role !== "canteen_admin" && req.user?.role !== "hr_admin" && req.user?.role !== "it_admin") {
    return res.status(403).json({ message: "Admin access only" });
  }
  next();
};
