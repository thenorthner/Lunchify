const mysql = require('mysql2/promise');
require('dotenv').config();

async function addColumn() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'lunchify',
  });

  try {
    await pool.query("ALTER TABLE otp_verifications ADD COLUMN employee_id VARCHAR(50) AFTER id");
    console.log("Successfully added employee_id column.");
  } catch(e) {
    console.log(e);
  }
  process.exit(0);
}
addColumn();
