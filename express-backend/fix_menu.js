const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  try {
    await c.query("INSERT INTO food_menu (menu_date, items, canteen_id) VALUES ('2026-07-03', '[\"chole\",\"chawal\"]', 4)");
    await c.query("INSERT INTO fruit_menu (menu_date, fruits, canteen_id) VALUES ('2026-07-03', '[\"tarbooj\",\"aam\"]', 4)");
    console.log("Copied menu to canteen 4");
  } catch(e) { console.log(e.message); }
  c.end();
}
run();
