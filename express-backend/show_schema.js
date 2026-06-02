const db = require('./db.js');
async function showSchema() {
  const [tables] = await db.query('SHOW TABLES');
  for (let row of tables) {
    const tableName = Object.values(row)[0];
    console.log(`\n--- TABLE: ${tableName} ---`);
    const [cols] = await db.query(`DESCRIBE ${tableName}`);
    cols.forEach(col => console.log(`${col.Field} - ${col.Type} - ${col.Null} - ${col.Key} - ${col.Default} - ${col.Extra}`));
  }
  process.exit(0);
}
showSchema();
