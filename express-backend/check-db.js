const { mysqlPool } = require('./db');

async function check() {
  try {
    const [rows] = await mysqlPool.query("SELECT * FROM users WHERE id = '30609' OR admin_id = '30609'");
    console.log("Database results for 30609:", JSON.stringify(rows, null, 2));
    process.exit(0);
  } catch (err) {
    console.error("Error checking db:", err);
    process.exit(1);
  }
}
check();
