require('dotenv').config();
const mysql = require('mysql2/promise');
async function setup() {
  const db = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'lunch_app'
  });
  
  await db.query(`
    CREATE TABLE IF NOT EXISTS daily_item_feedbacks (
      id INT AUTO_INCREMENT PRIMARY KEY,
      employee_id VARCHAR(50) NOT NULL,
      canteen_id INT NOT NULL,
      date DATE NOT NULL,
      item_name VARCHAR(100) NOT NULL,
      rating INT NOT NULL,
      remarks TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY emp_date_item (employee_id, date, item_name)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  console.log('Table daily_item_feedbacks created successfully.');
  db.end();
}
setup().catch(console.error);
