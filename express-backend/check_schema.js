require('dotenv').config();
const mysql = require('mysql2/promise');

async function checkSchema() {
  const db = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'lunch_coupon_db'
  });

  const [rows] = await db.query("DESCRIBE employees");
  console.log(rows);
  db.end();
}

checkSchema();
