const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  await c.query("ALTER TABLE users MODIFY COLUMN role ENUM('employee','canteen_admin','hr_admin','it_admin','scanner') DEFAULT 'employee'");
  console.log("Altered users role");
  c.end();
}
run();
