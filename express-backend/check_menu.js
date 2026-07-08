const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  try {
    const [rows1] = await c.query("SELECT * FROM users WHERE role='it_admin'");
    console.log("it admins:", rows1);
  } catch(e) { console.log(e.message); }
  c.end();
}
run();
