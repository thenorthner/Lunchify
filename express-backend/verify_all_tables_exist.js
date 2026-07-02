const mysql = require('mysql2/promise');
const fs = require('fs');

async function run() {
  const connection = await mysql.createConnection({host: 'localhost', user: 'root', password: '', database: 'lunch_app'});
  const [rows] = await connection.query("SHOW TABLES");
  const existingTables = rows.map(r => Object.values(r)[0]);
  
  const possibleTables = [
    'audit_logs', 'canteens', 'coupon_rates', 'coupon_shares', 
    'daily_item_feedbacks', 'feedbacks', 'food_lunch_orders', 
    'food_lunch_qr_tokens', 'food_menu', 'fruit_lunch_orders', 
    'fruit_menu', 'fruits', 'items', 'lunch_logs', 'menu', 
    'monthly_bills', 'orders', 'otp_verifications', 'projects', 
    'qr_codes', 'qr_scan_logs', 'rating', 'rooms', 'snack_orders', 
    'snacks_menu', 'transfer_requests', 'users', 'weekly_food_menu', 
    'weekly_fruit_menu', 'weekly_snacks_menu'
  ];

  console.log("Existing tables:", existingTables.join(", "));
  console.log("\nChecking for missing possible tables:");
  
  const missing = possibleTables.filter(t => !existingTables.includes(t));
  console.log(missing.length ? missing.join(", ") : "None");
  
  connection.end();
}
run();
