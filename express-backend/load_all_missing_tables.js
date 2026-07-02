const mysql = require('./db.js');
async function run() {
  try { await mysql.query("ALTER TABLE qr_scan_logs ADD COLUMN items JSON DEFAULT NULL;"); console.log("Added items to qr_scan_logs"); } catch(e) {}
  
  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS rooms (
        id INT AUTO_INCREMENT PRIMARY KEY,
        room_number VARCHAR(100),
        is_active BOOLEAN DEFAULT 1
      )
    `);
    // Seed some basic rooms if empty
    const [rows] = await mysql.query("SELECT count(*) as c FROM rooms");
    if (rows[0].c === 0) {
      await mysql.query("INSERT INTO rooms (room_number) VALUES ('101'), ('102'), ('103'), ('201'), ('202')");
    }
    console.log("rooms table created");
  } catch(e) { console.log(e); }

  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS lunch_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50),
        scan_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("lunch_logs table created");
  } catch(e) { console.log(e); }

  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS menu (
        id INT AUTO_INCREMENT PRIMARY KEY,
        date DATE,
        lunch_type VARCHAR(50),
        items JSON,
        UNIQUE KEY(date, lunch_type)
      )
    `);
    console.log("menu table created");
  } catch(e) { console.log(e); }

  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        status VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("orders table created");
  } catch(e) { console.log(e); }

  process.exit(0);
}
run();
