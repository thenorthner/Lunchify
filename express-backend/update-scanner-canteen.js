const mysql = require('mysql2/promise');
async function test() {
  try {
    const conn = await mysql.createConnection({ host: 'localhost', user: 'root', password: '', database: 'lunch_app' });
    await conn.query(`UPDATE users SET canteen_id=5 WHERE id='SCANNER001'`);
    await conn.query(`UPDATE qr_scan_logs SET canteen_id=5 WHERE scanned_by='SCANNER001' AND canteen_id IS NULL`);
    console.log('Scanner canteen_id and logs updated successfully.');
    await conn.end();
  } catch(e) {
    console.error('Error:', e.message);
  }
}
test();
