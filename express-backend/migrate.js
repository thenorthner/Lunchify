const db = require('./db.js');

async function migrate() {
  try {
    console.log("Adding admin_id to users...");
    await db.query("ALTER TABLE users ADD COLUMN admin_id VARCHAR(255) UNIQUE DEFAULT NULL;");
  } catch (err) {
    console.log(err.message);
  }

  try {
    console.log("Changing defaults to 16 for users...");
    await db.query("ALTER TABLE users ALTER COLUMN coupons_left SET DEFAULT 16;");
    await db.query("ALTER TABLE users ALTER COLUMN monthly_limit SET DEFAULT 16;");
  } catch (err) {
    console.log(err.message);
  }

  process.exit(0);
}

migrate();
