require('dotenv').config();
const db = require('./db');

async function checkLocations() {
  try {
    const [rows] = await db.query('SELECT DISTINCT location, COUNT(*) as count FROM users GROUP BY location');
    console.log(rows);
  } catch (err) {
    console.error(err);
  } finally {
    process.exit(0);
  }
}

checkLocations();
