const { mysqlPool } = require('./db');

async function inspect() {
  try {
    const [tables] = await mysqlPool.query("SHOW TABLES");
    console.log("=== TABLES ===");
    console.log(tables);

    for (let row of tables) {
      const tableName = Object.values(row)[0];
      const [columns] = await mysqlPool.query(`DESCRIBE \`${tableName}\``);
      console.log(`\n=== TABLE: ${tableName} ===`);
      console.log(columns.map(c => `${c.Field} (${c.Type})` + (c.Key ? ` [${c.Key}]` : '')));
    }
  } catch (err) {
    console.error("Inspection error:", err);
  } finally {
    process.exit(0);
  }
}

inspect();
