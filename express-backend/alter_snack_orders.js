const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  try {
    await c.query("ALTER TABLE snack_orders CHANGE total_amount total decimal(10,2) NO");
  } catch(e) {}
  try {
    await c.query("ALTER TABLE snack_orders ADD COLUMN room varchar(50) DEFAULT 'Self-Pickup'");
  } catch(e) {}
  try {
    await c.query("ALTER TABLE snack_orders ADD COLUMN session varchar(50) DEFAULT 'morning'");
  } catch(e) {}
  console.log("Altered snack_orders");
  c.end();
}
run();
