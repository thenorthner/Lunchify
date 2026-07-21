const mysql = require('mysql2/promise');
require('dotenv').config();

async function seedTestData() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'lunch_app'
  });

  try {
    console.log("Seeding test orders and snack orders...");

    const [users] = await connection.query("SELECT * FROM users WHERE role = 'employee' LIMIT 1");
    if (users.length === 0) {
      console.log("No employee found. Cannot seed orders.");
      return;
    }
    const user = users[0];

    const [canteens] = await connection.query("SELECT * FROM canteens LIMIT 1");
    const canteenId = canteens.length > 0 ? canteens[0].id : 1;
    
    const [admins] = await connection.query("SELECT * FROM users WHERE role = 'scanner' OR role = 'admin' LIMIT 1");
    const adminId = admins.length > 0 ? admins[0].id : 'admin_1';

    console.log("Seeding 20 past lunch qr_scan_logs...");
    for (let i = 1; i <= 20; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const formattedDate = date.toISOString().split('T')[0];
      
      const qrId = 'TEST_QR_' + i;
      
      await connection.query(`
        INSERT INTO qr_scan_logs (qr_id, scanned_by, lunch_type, canteen_id, created_at)
        VALUES (?, ?, 'regular', ?, ?)
      `, [qrId, adminId, canteenId, formattedDate + ' 13:00:00']);
      
      await connection.query("UPDATE users SET coupons_left = GREATEST(0, coupons_left - 1) WHERE id = ?", [user.id]);
    }

    console.log("Seeding 15 past snack orders...");
    for (let i = 1; i <= 15; i++) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        const formattedDate = date.toISOString().split('T')[0];
        
        await connection.query(`
            INSERT INTO snack_orders (employee_id, name, project_id, canteen_id, items, total_amount, status, date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, 'delivered', ?, ?)
        `, [
            user.id, user.name, user.project_id || 1, canteenId, 
            JSON.stringify([{id: 1, name: "Samosa", price: 15, quantity: 2}]), 
            30, 
            formattedDate,
            formattedDate + ' 16:30:00'
        ]);
    }

    console.log("✅ Successfully generated 5 hours worth of test data!");
  } catch (error) {
    console.error("Error seeding data:", error);
  } finally {
    await connection.end();
  }
}

seedTestData();
