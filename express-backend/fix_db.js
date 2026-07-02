const db = require('./db.js');
async function fix() {
  try {
    await db.query("ALTER TABLE users ADD COLUMN portal_password VARCHAR(255) DEFAULT NULL;");
    console.log("Added portal_password");
  } catch(e) { console.log(e.message); }
  process.exit(0);
}
fix();
