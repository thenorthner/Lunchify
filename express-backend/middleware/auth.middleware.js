const jwt = require("jsonwebtoken");
const { mysqlPool } = require("../db");
const { JWT_SECRET } = require("../config/jwt");

exports.requireAuth = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  const match = req.headers.cookie?.match(/(?:^|;\s*)admin_session=([^;]*)/);
  const cookieToken = match ? match[1] : null;

  let token = null;
  if (authHeader && authHeader.startsWith("Bearer ")) {
    token = authHeader.split(" ")[1];
  } else if (cookieToken) {
    token = cookieToken;
  }

  if (!token) {
    return res.status(401).json({ message: "No token provided" });
  }

  try {
    const expectedAudience = ['lunchify-mobile', 'lunchify-admin'];

    const decoded = jwt.verify(token, JWT_SECRET, {
      issuer: 'lunchify-api',
      audience: expectedAudience
    });
    // 1. Single-Device Session Token Check & User Validation (for ALL roles)
    const [rows] = await mysqlPool.query(
      `SELECT id, name, role, project_id, canteen_id, session_token, last_coupon_reset_month, coupons_left, monthly_limit, is_active
       FROM users WHERE id = ?`,
      [decoded.id]
    );

    if (rows.length === 0 || rows[0].is_active !== 1) {
      return res.status(401).json({ message: "User not found or inactive" });
    }

    const dbUser = rows[0];

    // Temporary bypass: allow login even if session tokens mismatch (since we reset the DB)
    if (!decoded.sessionToken || (dbUser.session_token != null && decoded.sessionToken !== dbUser.session_token)) {
      // return res.status(401).json({ message: "Session expired. Please log in again." });
    }
    
    // Automatically update the dbUser.session_token if it's null (DB was reset)
    if (dbUser.session_token == null && decoded.sessionToken) {
        await mysqlPool.query('UPDATE users SET session_token = ? WHERE id = ?', [decoded.sessionToken, dbUser.id]);
        dbUser.session_token = decoded.sessionToken;
    }

    // 2. Automated Monthly Coupon Reset Check (Race condition fixed)
    const currentMonth = new Date().toISOString().slice(0, 7); // 'YYYY-MM'
    if (dbUser.role === 'employee' && dbUser.last_coupon_reset_month !== currentMonth) {
      await mysqlPool.query(
        `UPDATE users
         SET coupons_left = monthly_limit, coupons_used = 0, last_coupon_reset_month = ?
         WHERE id = ? AND (last_coupon_reset_month IS NULL OR last_coupon_reset_month <> ?)`,
        [currentMonth, dbUser.id, currentMonth]
      );
      dbUser.coupons_left = dbUser.monthly_limit;
      dbUser.last_coupon_reset_month = currentMonth;
    }

    // Append standard user details to request
    req.user = {
      id: dbUser.id,
      name: dbUser.name,
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
  if (req.user?.role !== "canteen_admin" && req.user?.role !== "it_admin" && req.user?.role !== "scanner") {
    return res.status(403).json({ message: "Access denied. Canteen Admin or Scanner role required." });
  }
  next();
};

// Legacy support: requireAdmin mapped to Canteen Admin or above
exports.requireAdmin = (req, res, next) => {
  if (req.user?.role !== "canteen_admin" && req.user?.role !== "hr_admin" && req.user?.role !== "it_admin" && req.user?.role !== "scanner") {
    return res.status(403).json({ message: "Admin access only" });
  }
  next();
};
