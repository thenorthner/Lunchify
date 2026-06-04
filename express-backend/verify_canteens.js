require('dotenv').config();
const db = require('./db');

async function verify() {
    try {
        const [rows] = await db.query(`
            SELECT c.name as canteen_name, COUNT(u.id) as user_count 
            FROM users u
            JOIN canteens c ON u.canteen_id = c.id
            GROUP BY c.name
        `);
        console.table(rows);
    } catch(e) {
        console.error(e);
    } finally {
        process.exit(0);
    }
}
verify();
