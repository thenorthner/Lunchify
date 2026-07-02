const mysql = require('./db.js');
async function run() {
  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS otp_verifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50),
        phone_number VARCHAR(50),
        otp_code VARCHAR(10),
        expires_at DATETIME,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("otp_verifications created");
  } catch(e) { console.log(e); }
  
  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS audit_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        action VARCHAR(255),
        details TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("audit_logs created");
  } catch(e) { console.log(e); }

  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS food_lunch_qr_tokens (
        id INT AUTO_INCREMENT PRIMARY KEY,
        token VARCHAR(255),
        employee_id VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("food_lunch_qr_tokens created");
  } catch(e) { console.log(e); }
  
  process.exit(0);
}
run();
