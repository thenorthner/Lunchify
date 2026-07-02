const mysql = require('mysql2/promise');
async function run() {
  try {
    const c = await mysql.createConnection({host: 'localhost', user: 'root', password: ''});
    const [rows] = await c.query("SHOW DATABASES;");
    console.log(rows);
    c.end();
  } catch(e) { console.log(e); }
}
run();
