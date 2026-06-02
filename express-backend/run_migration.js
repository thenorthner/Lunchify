const mysql = require('mysql2/promise');
require('dotenv').config();

async function runMigration() {
  const host = process.env.DB_HOST || 'localhost';
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const database = process.env.DB_NAME || 'lunch_app';

  console.log(`Connecting to MySQL at ${host} as ${user}...`);

  // Connect to MySQL server without selecting database first
  const connection = await mysql.createConnection({ host, user, password });

  try {
    // Create database if not exists
    console.log(`Creating database ${database} if it doesn't exist...`);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${database}\``);
    await connection.end();

    // Reconnect to the specific database
    console.log(`Connecting to database ${database}...`);
    const pool = mysql.createPool({ host, user, password, database });

    console.log("Running schema migrations...");

    // 1. Projects Table
    console.log("Creating projects table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS projects (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        location VARCHAR(255) NOT NULL,
        state VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // 2. Canteens Table
    console.log("Creating canteens table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS canteens (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        location VARCHAR(255) NOT NULL,
        is_active TINYINT(1) DEFAULT 1,
        open_time TIME DEFAULT '07:00:00',
        close_time TIME DEFAULT '22:00:00',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    `);

    // 3. Seed Projects & Canteens if empty
    const [projectRows] = await pool.query("SELECT COUNT(*) as count FROM projects");
    if (projectRows[0].count === 0) {
      console.log("Seeding default projects and canteens...");
      await pool.query(`
        INSERT INTO projects (id, name, location, state) VALUES 
        (1, 'Shimla HQ', 'Shimla', 'Himachal Pradesh'),
        (2, 'Rampur Project', 'Rampur', 'Himachal Pradesh'),
        (3, 'Nathpa Jhakri Project', 'Nathpa Jhakri', 'Himachal Pradesh')
      `);

      await pool.query(`
        INSERT INTO canteens (id, project_id, name, location) VALUES 
        (1, 1, 'Shimla HQ Canteen', 'HQ Main Block'),
        (2, 2, 'Rampur Executive Canteen', 'Rampur Block A'),
        (3, 3, 'Nathpa Canteen', 'Nathpa Main Gate')
      `);
    }

    // 4. Modify/Create Users Table
    console.log("Checking and updating users table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        department VARCHAR(255),
        phone VARCHAR(20),
        password VARCHAR(255),
        is_registered TINYINT(1) DEFAULT 0,
        is_admin TINYINT(1) DEFAULT 0,
        is_active TINYINT(1) DEFAULT 1,
        coupons_left INT DEFAULT 16,
        coupons_used INT DEFAULT 0,
        monthly_limit INT DEFAULT 16,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Add new columns to users if they don't exist
    const [columns] = await pool.query("SHOW COLUMNS FROM users");
    const columnNames = columns.map(c => c.Field);

    if (!columnNames.includes('role')) {
      console.log("Adding column 'role' to users...");
      await pool.query("ALTER TABLE users ADD COLUMN role ENUM('employee', 'canteen_admin', 'hr_admin', 'it_admin') DEFAULT 'employee'");
    }
    if (!columnNames.includes('project_id')) {
      console.log("Adding column 'project_id' to users...");
      await pool.query("ALTER TABLE users ADD COLUMN project_id INT, ADD FOREIGN KEY (project_id) REFERENCES projects(id)");
    }
    if (!columnNames.includes('canteen_id')) {
      console.log("Adding column 'canteen_id' to users...");
      await pool.query("ALTER TABLE users ADD COLUMN canteen_id INT, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id)");
    }
    if (!columnNames.includes('last_coupon_reset_month')) {
      console.log("Adding column 'last_coupon_reset_month' to users...");
      await pool.query("ALTER TABLE users ADD COLUMN last_coupon_reset_month VARCHAR(7) DEFAULT '2026-05'");
    }
    if (!columnNames.includes('session_token')) {
      console.log("Adding column 'session_token' to users...");
      await pool.query("ALTER TABLE users ADD COLUMN session_token VARCHAR(255) DEFAULT NULL");
    }
    if (!columnNames.includes('device_id')) {
      console.log("Adding column 'device_id' to users...");
      await pool.query("ALTER TABLE users ADD COLUMN device_id VARCHAR(255) DEFAULT NULL");
    }

    // Set default assignments for legacy records
    await pool.query("UPDATE users SET project_id = 1, canteen_id = 1 WHERE project_id IS NULL");
    await pool.query("UPDATE users SET role = 'it_admin' WHERE is_admin = 1");
    await pool.query("UPDATE users SET role = 'employee' WHERE is_admin = 0 AND role IS NULL");

    // 5. Feedbacks Table
    console.log("Creating feedbacks table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS feedbacks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50) NOT NULL,
        canteen_id INT NOT NULL,
        subject VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        rating INT DEFAULT 5,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (canteen_id) REFERENCES canteens(id) ON DELETE CASCADE
      )
    `);

    // 6. Food, Fruit, Snacks Menu Tables
    console.log("Ensuring menu tables exist with canteen isolation...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS food_menu (
        id INT AUTO_INCREMENT PRIMARY KEY,
        menu_date DATE NOT NULL,
        items TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS fruit_menu (
        id INT AUTO_INCREMENT PRIMARY KEY,
        menu_date DATE NOT NULL,
        fruits TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS snacks_menu (
        id INT AUTO_INCREMENT PRIMARY KEY,
        menu_date DATE NOT NULL,
        session VARCHAR(50) NOT NULL,
        items TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Add canteen_id to menu tables if missing
    const [foodCols] = await pool.query("SHOW COLUMNS FROM food_menu");
    if (!foodCols.map(c => c.Field).includes('canteen_id')) {
      await pool.query("ALTER TABLE food_menu ADD COLUMN canteen_id INT DEFAULT 1, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id) ON DELETE CASCADE");
    }

    const [fruitCols] = await pool.query("SHOW COLUMNS FROM fruit_menu");
    if (!fruitCols.map(c => c.Field).includes('canteen_id')) {
      await pool.query("ALTER TABLE fruit_menu ADD COLUMN canteen_id INT DEFAULT 1, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id) ON DELETE CASCADE");
    }

    const [snackCols] = await pool.query("SHOW COLUMNS FROM snacks_menu");
    if (!snackCols.map(c => c.Field).includes('canteen_id')) {
      await pool.query("ALTER TABLE snacks_menu ADD COLUMN canteen_id INT DEFAULT 1, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id) ON DELETE CASCADE");
    }

    // 7. Food, Fruit, Snacks Order Tables
    console.log("Ensuring order tables exist with project/canteen isolation...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS food_lunch_orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50) NOT NULL,
        name VARCHAR(255) NOT NULL,
        quantity INT NOT NULL DEFAULT 1,
        order_type VARCHAR(50),
        room_number VARCHAR(50),
        delivery_time TIME,
        date DATE NOT NULL,
        status ENUM('pending', 'accepted', 'rejected', 'delivered', 'cancelled') DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        delivered_at TIMESTAMP NULL,
        FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS fruit_lunch_orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50) NOT NULL,
        name VARCHAR(255) NOT NULL,
        quantity INT NOT NULL DEFAULT 1,
        order_type VARCHAR(50),
        room_number VARCHAR(50),
        delivery_time TIME,
        date DATE NOT NULL,
        status ENUM('pending', 'accepted', 'rejected', 'delivered', 'cancelled') DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        delivered_at TIMESTAMP NULL,
        FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS snack_orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50) NOT NULL,
        name VARCHAR(255) NOT NULL,
        items TEXT NOT NULL,
        total_amount DECIMAL(10, 2) NOT NULL,
        date DATE NOT NULL,
        status ENUM('pending', 'delivered', 'cancelled') DEFAULT 'pending',
        payment_status ENUM('pending', 'paid') DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    // Add canteen_id and project_id to orders
    const [foodOrdCols] = await pool.query("SHOW COLUMNS FROM food_lunch_orders");
    if (!foodOrdCols.map(c => c.Field).includes('canteen_id')) {
      await pool.query("ALTER TABLE food_lunch_orders ADD COLUMN canteen_id INT DEFAULT 1, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id)");
    }
    if (!foodOrdCols.map(c => c.Field).includes('project_id')) {
      await pool.query("ALTER TABLE food_lunch_orders ADD COLUMN project_id INT DEFAULT 1, ADD FOREIGN KEY (project_id) REFERENCES projects(id)");
    }

    const [fruitOrdCols] = await pool.query("SHOW COLUMNS FROM fruit_lunch_orders");
    if (!fruitOrdCols.map(c => c.Field).includes('canteen_id')) {
      await pool.query("ALTER TABLE fruit_lunch_orders ADD COLUMN canteen_id INT DEFAULT 1, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id)");
    }
    if (!fruitOrdCols.map(c => c.Field).includes('project_id')) {
      await pool.query("ALTER TABLE fruit_lunch_orders ADD COLUMN project_id INT DEFAULT 1, ADD FOREIGN KEY (project_id) REFERENCES projects(id)");
    }

    const [snackOrdCols] = await pool.query("SHOW COLUMNS FROM snack_orders");
    if (!snackOrdCols.map(c => c.Field).includes('canteen_id')) {
      await pool.query("ALTER TABLE snack_orders ADD COLUMN canteen_id INT DEFAULT 1, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id)");
    }
    if (!snackOrdCols.map(c => c.Field).includes('project_id')) {
      await pool.query("ALTER TABLE snack_orders ADD COLUMN project_id INT DEFAULT 1, ADD FOREIGN KEY (project_id) REFERENCES projects(id)");
    }

    // 8. QR Codes & Logs
    console.log("Checking QR codes and scan logs...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS qr_codes (
        id VARCHAR(100) PRIMARY KEY,
        type VARCHAR(50) NOT NULL,
        used TINYINT(1) DEFAULT 0,
        used_by VARCHAR(50),
        used_at TIMESTAMP NULL
      )
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS qr_scan_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        qr_id VARCHAR(100) NOT NULL,
        scanned_by VARCHAR(50) NOT NULL,
        lunch_type VARCHAR(50) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    const [scanCols] = await pool.query("SHOW COLUMNS FROM qr_scan_logs");
    if (!scanCols.map(c => c.Field).includes('canteen_id')) {
      await pool.query("ALTER TABLE qr_scan_logs ADD COLUMN canteen_id INT DEFAULT 1, ADD FOREIGN KEY (canteen_id) REFERENCES canteens(id)");
    }

    // 9. Monthly Bills
    console.log("Creating monthly bills table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS monthly_bills (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50) NOT NULL,
        project_id INT NOT NULL,
        bill_month VARCHAR(7) NOT NULL,
        total_coupons_used INT NOT NULL DEFAULT 0,
        total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
        status ENUM('draft', 'submitted', 'approved', 'rejected') DEFAULT 'submitted',
        generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        place_generated VARCHAR(255) NOT NULL,
        FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    `);

    // 10. Transfer Requests
    console.log("Creating transfer requests table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS transfer_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        employee_id VARCHAR(50) NOT NULL,
        from_project_id INT NOT NULL,
        to_project_id INT NOT NULL,
        coupons_transferred INT NOT NULL,
        initiated_by VARCHAR(50) NOT NULL,
        transferred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (from_project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (to_project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (initiated_by) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    console.log("🎉 All migrations ran successfully!");
    await pool.end();
  } catch (err) {
    console.error("❌ Migration failed:", err);
  } finally {
    process.exit(0);
  }
}

runMigration();
