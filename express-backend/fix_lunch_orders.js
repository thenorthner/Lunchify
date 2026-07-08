const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  try {
    await c.query("ALTER TABLE fruit_lunch_orders ADD COLUMN items JSON DEFAULT NULL");
    console.log("Added items to fruit_lunch_orders");
  } catch(e) { console.log(e.message); }

  try {
    await c.query("ALTER TABLE food_lunch_orders ADD COLUMN items JSON DEFAULT NULL");
    console.log("Added items to food_lunch_orders");
  } catch(e) { console.log(e.message); }

  c.end();
}
run();
