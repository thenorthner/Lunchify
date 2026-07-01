const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkSchema() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'lunchify',
  });

  try {
    const [rows] = await pool.query("DESCRIBE otp_verifications");
    console.log("otp_verifications columns:");
    console.table(rows);
  } catch(e) {
    console.log(e);
  }
  process.exit(0);
}
checkSchema();
