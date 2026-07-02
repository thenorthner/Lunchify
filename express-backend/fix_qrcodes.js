const mysql = require('./db.js');
async function run() {
  try {
    await mysql.query("ALTER TABLE qr_codes ADD COLUMN employee_id VARCHAR(255) DEFAULT NULL;");
    console.log("Added employee_id to qr_codes");
  } catch(e) {
    console.log(e.message);
  } finally {
    process.exit(0);
  }
}
run();
