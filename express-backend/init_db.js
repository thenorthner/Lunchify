const fs = require('fs');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function initDB() {
  console.log('Connecting to Aiven Cloud DB...');
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      ssl: { rejectUnauthorized: false },
      multipleStatements: true
    });

    console.log('Connected successfully! Reading schema.sql...');
    let schema = fs.readFileSync('schema.sql', 'utf8');
    
    // Auto-fix table creation to ignore already existing tables
    schema = schema.replace(/CREATE TABLE /g, 'CREATE TABLE IF NOT EXISTS ');

    console.log('Disabling foreign key checks and executing schema...');
    await connection.query('SET FOREIGN_KEY_CHECKS = 0;');
    await connection.query(schema);
    await connection.query('SET FOREIGN_KEY_CHECKS = 1;');

    console.log('Schema imported successfully!');
    await connection.end();
  } catch (error) {
    console.error('Error importing schema:', error);
  }
}

initDB();
