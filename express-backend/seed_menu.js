const db = require('./db');

async function seedWeeklyMenu() {
  try {
    const canteens = [1, 2, 3, 4];
    const today = new Date('2026-07-06');

    // Premium Indian/Continental Dummy Menu
    const foodItems = [
      '[{"name": "Paneer Butter Masala", "type": "veg"}, {"name": "Dal Makhani", "type": "veg"}, {"name": "Jeera Rice", "type": "veg"}, {"name": "Butter Naan", "type": "veg"}, {"name": "Gulab Jamun", "type": "veg"}]',
      '[{"name": "Chicken Tikka Masala", "type": "non-veg"}, {"name": "Mix Veg Curry", "type": "veg"}, {"name": "Veg Pulao", "type": "veg"}, {"name": "Tandoori Roti", "type": "veg"}, {"name": "Rasgulla", "type": "veg"}]',
      '[{"name": "Chole Bhature", "type": "veg"}, {"name": "Aloo Gobi", "type": "veg"}, {"name": "Boondi Raita", "type": "veg"}, {"name": "Papad", "type": "veg"}, {"name": "Gajar Halwa", "type": "veg"}]',
      '[{"name": "Mutton Biryani", "type": "non-veg"}, {"name": "Mirchi Ka Salan", "type": "veg"}, {"name": "Raita", "type": "veg"}, {"name": "Double Ka Meetha", "type": "veg"}]',
      '[{"name": "Palak Paneer", "type": "veg"}, {"name": "Dal Tadka", "type": "veg"}, {"name": "Steamed Rice", "type": "veg"}, {"name": "Chapati", "type": "veg"}, {"name": "Ice Cream", "type": "veg"}]',
      '[{"name": "Rajma Chawal", "type": "veg"}, {"name": "Bhindi Masala", "type": "veg"}, {"name": "Green Salad", "type": "veg"}, {"name": "Kheer", "type": "veg"}]',
      '[{"name": "Special Veg Thali", "type": "veg"}, {"name": "Kadai Paneer", "type": "veg"}, {"name": "Malai Kofta", "type": "veg"}, {"name": "Butter Roti", "type": "veg"}, {"name": "Jalebi", "type": "veg"}]'
    ];

    const fruitItems = [
      '[{"name": "Apple", "type": "veg"}, {"name": "Banana", "type": "veg"}, {"name": "Grapes", "type": "veg"}]',
      '[{"name": "Watermelon", "type": "veg"}, {"name": "Papaya", "type": "veg"}, {"name": "Pineapple", "type": "veg"}]',
      '[{"name": "Mango", "type": "veg"}, {"name": "Pomegranate", "type": "veg"}, {"name": "Guava", "type": "veg"}]',
      '[{"name": "Orange", "type": "veg"}, {"name": "Sweet Lime", "type": "veg"}, {"name": "Kiwi", "type": "veg"}]',
      '[{"name": "Dragon Fruit", "type": "veg"}, {"name": "Apple", "type": "veg"}, {"name": "Banana", "type": "veg"}]',
      '[{"name": "Strawberry", "type": "veg"}, {"name": "Blueberry", "type": "veg"}, {"name": "Pear", "type": "veg"}]',
      '[{"name": "Mixed Fruit Bowl", "type": "veg"}]'
    ];

    const morningSnacks = [
      '[{"name": "Samosa", "price": 15}, {"name": "Kachori", "price": 15}, {"name": "Masala Chai", "price": 10}]',
      '[{"name": "Poha", "price": 25}, {"name": "Jalebi", "price": 20}, {"name": "Coffee", "price": 15}]',
      '[{"name": "Aloo Paratha", "price": 30}, {"name": "Curd", "price": 10}, {"name": "Tea", "price": 10}]',
      '[{"name": "Idli Sambar", "price": 35}, {"name": "Vada", "price": 15}, {"name": "Filter Coffee", "price": 15}]',
      '[{"name": "Bread Pakora", "price": 20}, {"name": "Green Chutney", "price": 0}, {"name": "Masala Chai", "price": 10}]',
      '[{"name": "Upma", "price": 25}, {"name": "Kesari Bath", "price": 20}, {"name": "Tea", "price": 10}]',
      '[{"name": "Chole Bhature", "price": 50}, {"name": "Lassi", "price": 25}]'
    ];

    const eveningSnacks = [
      '[{"name": "Vada Pav", "price": 20}, {"name": "Cutting Chai", "price": 10}]',
      '[{"name": "Bhel Puri", "price": 30}, {"name": "Sev Puri", "price": 30}, {"name": "Cold Drink", "price": 20}]',
      '[{"name": "Pav Bhaji", "price": 50}, {"name": "Tawa Pulao", "price": 60}]',
      '[{"name": "Paneer Roll", "price": 45}, {"name": "Egg Roll", "price": 35}, {"name": "Lemon Tea", "price": 15}]',
      '[{"name": "Momos (Veg)", "price": 40}, {"name": "Momos (Chicken)", "price": 50}, {"name": "Soup", "price": 20}]',
      '[{"name": "Dabeli", "price": 25}, {"name": "Kachori", "price": 15}, {"name": "Tea", "price": 10}]',
      '[{"name": "French Fries", "price": 40}, {"name": "Burger", "price": 50}, {"name": "Cold Coffee", "price": 35}]'
    ];

    // Clear existing menu for the week to avoid duplicates
    for (let i = 0; i < 7; i++) {
      let dateObj = new Date(today);
      dateObj.setDate(today.getDate() + i);
      let dateStr = dateObj.toISOString().split('T')[0];
      
      await db.query(`DELETE FROM food_menu WHERE menu_date = ?`, [dateStr]);
      await db.query(`DELETE FROM fruit_menu WHERE menu_date = ?`, [dateStr]);
      await db.query(`DELETE FROM snacks_menu WHERE menu_date = ?`, [dateStr]);

      for (let canteen_id of canteens) {
        // Insert Food
        await db.query(
          `INSERT INTO food_menu (canteen_id, menu_date, items) VALUES (?, ?, ?)`,
          [canteen_id, dateStr, foodItems[i]]
        );
        
        // Insert Fruit
        await db.query(
          `INSERT INTO fruit_menu (canteen_id, menu_date, fruits) VALUES (?, ?, ?)`,
          [canteen_id, dateStr, fruitItems[i]]
        );
        
        // Insert Snacks (Morning)
        await db.query(
          `INSERT INTO snacks_menu (canteen_id, menu_date, session, items) VALUES (?, ?, ?, ?)`,
          [canteen_id, dateStr, 'Morning', morningSnacks[i]]
        );
        
        // Insert Snacks (Evening)
        await db.query(
          `INSERT INTO snacks_menu (canteen_id, menu_date, session, items) VALUES (?, ?, ?, ?)`,
          [canteen_id, dateStr, 'Evening', eveningSnacks[i]]
        );
      }
      console.log(`Inserted menu for ${dateStr}`);
    }

    console.log("Weekly dummy menu seeded successfully!");
    process.exit(0);
  } catch (err) {
    console.error("Error seeding menu:", err);
    process.exit(1);
  }
}

seedWeeklyMenu();
