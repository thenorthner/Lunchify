const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [rows] = await c.query("SELECT id, role, is_active FROM users WHERE id IN ('CANTEEN001', 'HR001')");
  console.log(rows);
  c.end();
}
run();
