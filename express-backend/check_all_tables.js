const mysql = require('mysql2/promise');
async function check() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [tables] = await c.query("SHOW TABLES");
  console.log("Checking tables in lunch_app...\n");
  for (let t of tables) {
    let tableName = Object.values(t)[0];
    let [rows] = await c.query(`SELECT COUNT(*) as count FROM ${tableName}`);
    console.log(`- ${tableName}: ${rows[0].count} rows`);
  }
  console.log("\nAll tables seem to be present.");
  c.end();
}
check().catch(console.error);
