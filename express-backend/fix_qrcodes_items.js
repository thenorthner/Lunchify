const mysql = require('./db.js');
async function run() {
  try {
    await mysql.query("ALTER TABLE qr_codes ADD COLUMN items JSON DEFAULT NULL;");
    console.log("Added items to qr_codes");
  } catch(e) {
    console.log(e.message);
  } finally {
    process.exit(0);
  }
}
run();
