const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const hash = await bcrypt.hash('admin', 10);
  await c.query(
    "INSERT INTO users (id, admin_id, name, portal_password, role, is_active, canteen_id, project_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
    ['SCANNER001', 'SCANNER001', 'Canteen Scanner 1', hash, 'scanner', 1, 1, 1]
  );
  console.log("Scanner created");
  c.end();
}
run();
