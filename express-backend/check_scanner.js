const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [rows] = await c.query("SELECT * FROM users WHERE id = 'SCANNER001' OR admin_id = 'SCANNER001'");
  console.log(rows);
  c.end();
}
run();
