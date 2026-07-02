const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [rows] = await c.query("SELECT * FROM qr_codes WHERE id = 'c3c4fe1b-a2fa-4a01-b2ef-c351926b5074'");
  console.log(rows);
  c.end();
}
run();
