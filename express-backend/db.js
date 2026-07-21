const mysql = require('mysql2/promise');
require('dotenv').config();

const mysqlPool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'lunch_app',
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 10000,
});

mysqlPool
  .getConnection()
  .then(conn => {
    console.log('✅ MySQL connected successfully');
    conn.release();
  })
  .catch(err => {
    console.error('❌ MySQL connection failed:', err.message || err);
    if (err.code === 'ENOTFOUND') {
      console.error('   → Database hostname could not be resolved. Check DB_HOST in .env');
      console.error('   → For local dev use: DB_HOST=localhost, DB_NAME=lunch_app, DB_SSL=false');
    } else if (err.code === 'ER_ACCESS_DENIED_ERROR') {
      console.error('   → Wrong MySQL username/password. Update DB_USER and DB_PASSWORD in .env');
    } else if (err.code === 'ECONNREFUSED' || err.code === 'ER_BAD_DB_ERROR') {
      console.error('   → MySQL not running or database missing. Start MySQL and run: CREATE DATABASE lunch_app;');
    }
  });

// Support both direct imports and destructured imports seamlessly
mysqlPool.mysqlPool = mysqlPool;
mysqlPool.db = mysqlPool;
mysqlPool.getDB = () => mysqlPool;

module.exports = mysqlPool;
