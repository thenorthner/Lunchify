const { mysqlPool } = require('./db.js');

async function fixEnum() {
  try {
    console.log("Fixing enum...");
    await mysqlPool.query("ALTER TABLE monthly_bills MODIFY COLUMN status enum('draft','submitted','approved','rejected','review') DEFAULT 'submitted'");
    console.log("Enum fixed!");
  } catch (err) {
    console.error("Error:", err);
  } finally {
    process.exit(0);
  }
}
fixEnum();
