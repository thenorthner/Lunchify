const db = require('./db.js');
async function fix() {
  try {
    await db.query("ALTER TABLE users ADD COLUMN designation VARCHAR(255) DEFAULT NULL;");
    console.log("Added designation");
  } catch(e) { console.log(e.message); }
  process.exit(0);
}
fix();
