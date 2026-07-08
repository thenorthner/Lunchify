const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const hash = await bcrypt.hash('admin', 10);
  
  await c.query("UPDATE users SET is_registered = 1, portal_password = ? WHERE id IN ('CANTEEN001', 'HR001')", [hash]);
  
  console.log("Updated CANTEEN001 and HR001");
  c.end();
}
run();
