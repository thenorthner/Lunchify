const mysql = require('mysql2/promise');
require('dotenv').config();

const mysqlPool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'lunch_app',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

mysqlPool
  .getConnection()
  .then(conn => {
    console.log('✅ MySQL connected successfully');
    conn.release();
  })
  .catch(err => {
    console.error('❌ MySQL connection failed:', err);
  });

// Support both direct imports and destructured imports seamlessly
mysqlPool.mysqlPool = mysqlPool;
mysqlPool.db = mysqlPool;
mysqlPool.getDB = () => mysqlPool;

module.exports = mysqlPool;
