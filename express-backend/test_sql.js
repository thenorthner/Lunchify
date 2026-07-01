require('dotenv').config();
const mysql = require('mysql2/promise');

(async () => {
  const p = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  });
  try {
    const employeeId = '30609';
    const likeMonth = '2026-06%';
    const query = `
      SELECT 'lunch' as usage_type, quantity as amount, CONCAT(DATE_FORMAT(created_at, '%Y-%m-%dT%T'), 'Z') as used_at, CONCAT('Pre-ordered Food: ', name) as description 
      FROM food_lunch_orders WHERE employee_id = ? AND created_at LIKE ?
      UNION ALL
      SELECT 'fruit' as usage_type, quantity as amount, CONCAT(DATE_FORMAT(created_at, '%Y-%m-%dT%T'), 'Z') as used_at, CONCAT('Pre-ordered Fruit: ', name) as description 
      FROM fruit_lunch_orders WHERE employee_id = ? AND created_at LIKE ?
      UNION ALL
      SELECT 'sharing' as usage_type, amount, CONCAT(DATE_FORMAT(shared_at, '%Y-%m-%dT%T'), 'Z') as used_at, CONCAT('Shared with: ', u.name) as description 
      FROM coupon_shares c JOIN users u ON c.receiver_id = u.id WHERE sender_id = ? AND shared_at LIKE ?
      UNION ALL
      SELECT 'received' as usage_type, amount, CONCAT(DATE_FORMAT(shared_at, '%Y-%m-%dT%T'), 'Z') as used_at, CONCAT('Received from: ', u.name) as description 
      FROM coupon_shares c JOIN users u ON c.sender_id = u.id WHERE receiver_id = ? AND shared_at LIKE ?
      UNION ALL
      SELECT 'lunch' as usage_type, 1 as amount, CONCAT(DATE_FORMAT(qsl.created_at, '%Y-%m-%dT%T'), 'Z') as used_at, 'Instant QR Scan at Canteen' as description 
      FROM qr_scan_logs qsl 
      JOIN qr_codes q ON qsl.qr_id = q.id 
      WHERE q.employee_id = ? AND q.type = 'instant' AND qsl.created_at LIKE ?
      ORDER BY used_at DESC
    `;
    const [rows] = await p.query(query, [employeeId, likeMonth, employeeId, likeMonth, employeeId, likeMonth, employeeId, likeMonth, employeeId, likeMonth]);
    console.log(rows);
  } catch(e) {
    console.error("SQL Error:", e);
  }
  process.exit();
})();
