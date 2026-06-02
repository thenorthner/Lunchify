const { mysqlPool } = require('./db.js');

async function main() {
  const [food] = await mysqlPool.query("SELECT * FROM food_lunch_orders");
  const [fruit] = await mysqlPool.query("SELECT * FROM fruit_lunch_orders");
  console.log("FOOD LUNCH ORDERS:", food);
  console.log("FRUIT LUNCH ORDERS:", fruit);
  process.exit(0);
}

main();
