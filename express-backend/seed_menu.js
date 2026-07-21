require('dotenv').config({ path: __dirname + '/.env' });
const mysql = require('mysql2/promise');

async function seedWeeklyMenu() {
  let pool;
  try {
    pool = mysql.createPool({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit: 10,
    });
    
    // Test connection
    await pool.query('SELECT 1');
    console.log('? MySQL connected successfully');

    const defaultMenu = {
      'Monday': [
        { name: 'Paneer Butter Masala', type: 'veg' },
        { name: 'Dal Makhani', type: 'veg' },
        { name: 'Jeera Rice', type: 'veg' },
        { name: 'Butter Naan', type: 'veg' },
        { name: 'Gulab Jamun', type: 'veg' }
      ],
      'Tuesday': [
        { name: 'Mixed Veg Curry', type: 'veg' },
        { name: 'Yellow Dal Tadka', type: 'veg' },
        { name: 'Peas Pulao', type: 'veg' },
        { name: 'Tandoori Roti', type: 'veg' },
        { name: 'Rasgulla', type: 'veg' }
      ],
      'Wednesday': [
        { name: 'Palak Paneer', type: 'veg' },
        { name: 'Chana Masala', type: 'veg' },
        { name: 'Steamed Rice', type: 'veg' },
        { name: 'Missi Roti', type: 'veg' },
        { name: 'Kheer', type: 'veg' }
      ],
      'Thursday': [
        { name: 'Malai Kofta', type: 'veg' },
        { name: 'Rajma Masala', type: 'veg' },
        { name: 'Veg Biryani', type: 'veg' },
        { name: 'Garlic Naan', type: 'veg' },
        { name: 'Gajar Ka Halwa', type: 'veg' }
      ],
      'Friday': [
        { name: 'Kadai Paneer', type: 'veg' },
        { name: 'Dal Fry', type: 'veg' },
        { name: 'Veg Pulao', type: 'veg' },
        { name: 'Plain Naan', type: 'veg' },
        { name: 'Ice Cream', type: 'veg' }
      ],
      'Saturday': [
        { name: 'Aloo Gobi', type: 'veg' },
        { name: 'Dal Tadka', type: 'veg' },
        { name: 'Jeera Rice', type: 'veg' },
        { name: 'Chapati', type: 'veg' },
        { name: 'Fruit Salad', type: 'veg' }
      ],
      'Sunday': [
        { name: 'Chole Bhature', type: 'veg' },
        { name: 'Aloo Sabzi', type: 'veg' },
        { name: 'Pulao', type: 'veg' },
        { name: 'Puri', type: 'veg' },
        { name: 'Jalebi', type: 'veg' }
      ]
    };

    // Current week starting from Monday
    const today = new Date();
    const day = today.getDay();
    const diff = today.getDate() - day + (day === 0 ? -6 : 1); // adjust when day is sunday
    const startDate = new Date(today.setDate(diff));

    const [canteens] = await pool.query('SELECT id FROM canteens LIMIT 1');
    const canteenId = canteens[0].id;

    for (let i = 0; i < 7; i++) {
      const currentDate = new Date(startDate);
      currentDate.setDate(startDate.getDate() + i);
      const dateString = currentDate.toISOString().split('T')[0];
      const dayName = currentDate.toLocaleDateString('en-US', { weekday: 'long' });

      const dayMenu = defaultMenu[dayName] || defaultMenu['Monday'];

      await pool.query(
        'INSERT IGNORE INTO food_menu (canteen_id, menu_date, items) VALUES (?, ?, ?)',
        [canteenId, dateString, JSON.stringify(dayMenu)]
      );
    }
    
    console.log('? Weekly menu seeded successfully');
  } catch (err) {
    console.error('Error seeding menu:', err);
  } finally {
    if (pool) await pool.end();
  }
}

seedWeeklyMenu();
