const { mysqlPool } = require('../db');

async function inspectSchema() {
  try {
    const [rows] = await mysqlPool.query("SHOW CREATE TABLE `fruit_menu`");
    console.log("=== SHOW CREATE TABLE fruit_menu ===");
    console.log(rows[0]['Create Table']);
  } catch (err) {
    console.error("Error inspecting schema:", err);
  } finally {
    process.exit(0);
  }
}

inspectSchema();
