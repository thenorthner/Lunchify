const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [rows] = await c.query("SELECT id, is_registered, password FROM users WHERE id = '30609'");
  console.log(rows);
  c.end();
}
run();
