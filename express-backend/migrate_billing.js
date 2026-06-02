const { mysqlPool } = require('./db.js');

async function migrate() {
  try {
    console.log("Migrating monthly_bills table...");

    await mysqlPool.query("ALTER TABLE monthly_bills MODIFY employee_id VARCHAR(50) NULL");
    
    const [cols] = await mysqlPool.query("SHOW COLUMNS FROM monthly_bills");
    const colNames = cols.map(c => c.Field);

    if (!colNames.includes('canteen_id')) {
      await mysqlPool.query("ALTER TABLE monthly_bills ADD COLUMN canteen_id INT DEFAULT 1");
      console.log("Added canteen_id column.");
    }
    if (!colNames.includes('coupon_price')) {
      await mysqlPool.query("ALTER TABLE monthly_bills ADD COLUMN coupon_price DECIMAL(10,2) DEFAULT 0.00");
      console.log("Added coupon_price column.");
    }
    if (!colNames.includes('comments')) {
      await mysqlPool.query("ALTER TABLE monthly_bills ADD COLUMN comments TEXT NULL");
      console.log("Added comments column.");
    }

    console.log("Migration completed.");
  } catch (err) {
    console.error("Migration failed:", err);
  } finally {
    process.exit(0);
  }
}

migrate();
