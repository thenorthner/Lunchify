const mysql = require('mysql2/promise');
const fs = require('fs');

async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [tables] = await c.query('SHOW TABLES');
  let schema = '';
  for (let t of tables) {
    const tableName = Object.values(t)[0];
    const [createRes] = await c.query(`SHOW CREATE TABLE \`${tableName}\``);
    schema += createRes[0]['Create Table'] + ';\n\n';
  }
  fs.writeFileSync('schema.sql', schema);
  console.log('Schema saved to schema.sql');
  c.end();
}
run();
