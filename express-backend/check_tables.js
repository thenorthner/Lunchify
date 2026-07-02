const mysql = require('mysql2/promise');
async function run() {
  try {
    const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
    const [rows] = await c.query("SHOW TABLES;");
    console.log(rows);
    c.end();
  } catch(e) { console.log(e); }
}
run();
