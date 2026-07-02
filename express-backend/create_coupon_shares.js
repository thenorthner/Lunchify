const mysql = require('./db.js');
async function run() {
  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS coupon_shares (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id VARCHAR(255) NOT NULL,
        receiver_id VARCHAR(255) NOT NULL,
        amount INT NOT NULL,
        shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("coupon_shares table created");
  } catch (e) {
    console.error(e);
  } finally {
    process.exit();
  }
}
run();
