const mysql = require('mysql2/promise');

async function test() {
  try {
    const conn = await mysql.createConnection({ host: 'localhost', user: 'root', password: '', database: 'lunch_app' });
    await conn.query("ALTER TABLE users MODIFY COLUMN role ENUM('employee','canteen_admin','hr_admin','it_admin','scanner') DEFAULT 'employee'");
    await conn.query("UPDATE users SET role='scanner' WHERE id='SCANNER001'");
    console.log('Role updated successfully.');
    await conn.end();
  } catch(e) {
    console.error('Error:', e.message);
  }
}
test();
