const { mysqlPool } = require('./db');
const bcrypt = require('bcryptjs');

async function seed() {
  if (process.env.NODE_ENV === 'production') {
    console.error("FATAL: Cannot run seed script in production environment.");
    process.exit(1);
  }
  try {
    const password = 'admin';
    const hash = await bcrypt.hash(password, 10);
    console.log(`Generated bcrypt hash for "${password}": ${hash}`);

    // Clean up existing test users if they exist to avoid primary key collisions
    await mysqlPool.query("DELETE FROM users WHERE id IN ('IT001', 'HR001', 'CANTEEN001', 'EMP001')");

    // Fetch first project and canteen
    const [projects] = await mysqlPool.query('SELECT id FROM projects LIMIT 1');
    const [canteens] = await mysqlPool.query('SELECT id FROM canteens LIMIT 1');
    
    if (projects.length === 0 || canteens.length === 0) {
      throw new Error("No projects or canteens found. Run seed_canteens.js first.");
    }
    
    const projectId = projects[0].id;
    const canteenId = canteens[0].id;

    // Seed users
    console.log("Seeding test administrators and employees...");
    
    // IT Admin (role = 'it_admin')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, portal_password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, ?, 1, 1, 1, 'it_admin', ?, ?, 16)
    `, ['IT001', 'Demo IT Admin', 'IT Department', '9999999999', hash, hash, projectId, canteenId]);

    // HR Admin (role = 'hr_admin')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, portal_password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, ?, 1, 0, 1, 'hr_admin', ?, ?, 16)
    `, ['HR001', 'Demo HR Admin', 'HR Department', '8888888888', hash, hash, projectId, canteenId]);

    // Canteen Admin (role = 'canteen_admin')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, portal_password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, ?, 1, 0, 1, 'canteen_admin', ?, ?, 16)
    `, ['CANTEEN001', 'Demo Canteen Admin', 'F&B Operations', '7777777777', hash, hash, projectId, canteenId]);

    // Demo Employee (role = 'employee')
    await mysqlPool.query(`
      INSERT INTO users (id, name, department, phone, password, portal_password, is_registered, is_admin, is_active, role, project_id, canteen_id, coupons_left)
      VALUES (?, ?, ?, ?, ?, ?, 1, 0, 1, 'employee', ?, ?, 16)
    `, ['EMP001', 'Demo Employee', 'Engineering', '6666666666', hash, hash, projectId, canteenId]);

    console.log("✅ Admin seeding completed successfully!");
  } catch (err) {
    console.error("❌ Seeding failed:", err);
  } finally {
    process.exit(0);
  }
}

seed();
