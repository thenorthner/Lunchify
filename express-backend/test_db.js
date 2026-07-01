require('dotenv').config();
const mysql = require('mysql2/promise');

(async () => {
  const p = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  });

  const [r] = await p.query(`
    SELECT label, SUM(count) as count FROM (
      SELECT DATE_FORMAT(created_at, '%Y-%m') as label, COUNT(*) as count 
      FROM qr_scan_logs 
      WHERE canteen_id = 5 
      GROUP BY label 
      UNION ALL
      SELECT DATE_FORMAT(created_at, '%Y-%m') as label, SUM(quantity) as count 
      FROM fruit_lunch_orders 
      WHERE canteen_id = 5 
      GROUP BY label
    ) t
    GROUP BY label
    ORDER BY label DESC
  `);
  console.log("DB response:", r);
  process.exit();
})();
