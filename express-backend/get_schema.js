const db = require('./db.js');
async function run() {
  try {
    const [rows] = await db.query("DESCRIBE users;");
    console.log(rows);
  } catch(e) { console.log(e); }
  process.exit(0);
}
run();
