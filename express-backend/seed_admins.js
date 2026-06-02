const { mysqlPool } = require('./db');
const bcrypt = require('bcryptjs');

async function seed() {
  try {
    const password = 'admin';
    const hash = await bcrypt.hash(password, 10);
    console.log(`Generated bcrypt hash for "${password}": ${hash}`);

    // Clean up existing test users if they exist to avoid primary key collisions
    await mysqlPool.query("DELETE FROM users WHERE id IN ('IT001', 'HR001', 'CANTEEN001', 'EMP001')");

    // Seed users
    console.log("Seeding test administrators and employees...");
    
    // IT Admin (role = 'it_admin')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, 1, 1, 1, 'it_admin', 1, 1, 16)
    `, ['IT001', 'Demo IT Admin', 'IT Department', '9999999999', hash]);

    // HR Admin (role = 'hr_admin')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, 1, 0, 1, 'hr_admin', 1, 1, 16)
    `, ['HR001', 'Demo HR Admin', 'HR Department', '8888888888', hash]);

    // Canteen Admin (role = 'canteen_admin')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, 1, 0, 1, 'canteen_admin', 1, 1, 16)
    `, ['CANTEEN001', 'Demo Canteen Admin', 'F&B Operations', '7777777777', hash]);

    // Demo Employee (role = 'employee')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, 1, 0, 1, 'employee', 1, 1, 16)
    `, ['EMP001', 'Demo Employee', 'Engineering', '6666666666', hash]);

    console.log("✅ Admin seeding completed successfully!");
  } catch (err) {
    console.error("❌ Seeding failed:", err);
  } finally {
    process.exit(0);
  }
}

seed();
