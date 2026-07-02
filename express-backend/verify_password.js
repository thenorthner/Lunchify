const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [rows] = await c.query("SELECT password FROM users WHERE id = '30609'");
  
  if (rows.length > 0) {
    const isMatch = await bcrypt.compare('123456', rows[0].password);
    console.log("Password '123456' matches:", isMatch);
  } else {
    console.log("User not found");
  }
  c.end();
}
run();
