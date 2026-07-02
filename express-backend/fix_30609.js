const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const defaultPassword = await bcrypt.hash('123456', 10);
  await c.query("UPDATE users SET is_registered = 1, password = ? WHERE id = '30609'", [defaultPassword]);
  console.log("Updated 30609");
  c.end();
}
run();
