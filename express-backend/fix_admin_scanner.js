const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const hash = await bcrypt.hash('admin', 10);
  
  await c.query("UPDATE users SET is_registered = 1, portal_password = ? WHERE id IN ('SCANNER001', 'IT001')", [hash]);
  
  console.log("Updated IT001 and SCANNER001");
  c.end();
}
run();
