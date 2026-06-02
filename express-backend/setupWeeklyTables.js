const mysql = require('./db.js');

async function setupWeeklyTables() {
  try {
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS weekly_food_menu (
        id INT AUTO_INCREMENT PRIMARY KEY,
        day_of_week INT NOT NULL,
        items JSON NOT NULL,
        canteen_id INT DEFAULT 1,
        UNIQUE KEY(day_of_week, canteen_id)
      )
    `);
    console.log('weekly_food_menu created');
    
    await mysql.query(`
      CREATE TABLE IF NOT EXISTS weekly_fruit_menu (
        id INT AUTO_INCREMENT PRIMARY KEY,
        day_of_week INT NOT NULL,
        fruits JSON NOT NULL,
        canteen_id INT DEFAULT 1,
        UNIQUE KEY(day_of_week, canteen_id)
      )
    `);
    console.log('weekly_fruit_menu created');

    await mysql.query(`
      CREATE TABLE IF NOT EXISTS weekly_snacks_menu (
        id INT AUTO_INCREMENT PRIMARY KEY,
        day_of_week INT NOT NULL,
        session ENUM('morning', 'evening') NOT NULL,
        items JSON NOT NULL,
        canteen_id INT DEFAULT 1,
        UNIQUE KEY(day_of_week, session, canteen_id)
      )
    `);
    console.log('weekly_snacks_menu created');
  } catch(e) {
    console.error(e);
  } finally {
    process.exit();
  }
}

setupWeeklyTables();
