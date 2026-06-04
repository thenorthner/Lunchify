require('dotenv').config();
const mysql = require('mysql2/promise');
const xlsx = require('xlsx');
const bcrypt = require('bcryptjs'); // Package used in this project is bcryptjs!

async function importData() {
  const filePath = '../Employee master data.xlsx';
  const workbook = xlsx.readFile(filePath);
  const sheet = workbook.Sheets[workbook.SheetNames[0]];
  const data = xlsx.utils.sheet_to_json(sheet);

  const db = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'lunch_app'
  });

  const defaultPassword = await bcrypt.hash('123456', 10);
  
  let inserted = 0;
  let updated = 0;
  let skipped = 0;

  for (const row of data) {
    const empNo = row['Emp No'] ? String(row['Emp No']).trim() : '';
    const name = row['Employee Name'] ? String(row['Employee Name']).trim() : '';
    const dept = row['Department'] ? String(row['Department']).trim() : '';
    let phone = row['Phone'] ? String(row['Phone']).trim() : null;
    if (phone === 'null' || phone === 'undefined') phone = null;
    
    if (!empNo) {
      skipped++;
      continue;
    }

    try {
      // Check if user exists
      const [existing] = await db.query('SELECT id FROM users WHERE id = ?', [empNo]);
      if (existing.length > 0) {
        // Update user
        await db.query(
          'UPDATE users SET name = ?, department = ?, phone = ?, project_id = 1, canteen_id = 1 WHERE id = ?',
          [name, dept, phone, empNo]
        );
        updated++;
      } else {
        // Insert new user
        // Using role = employee, project_id = 1 (Shimla HQ), canteen_id = 1 (Shimla HQ Canteen)
        await db.query(
          `INSERT INTO users (id, name, department, phone, password, role, is_registered, is_active, coupons_left, coupons_used, monthly_limit, project_id, canteen_id) 
           VALUES (?, ?, ?, ?, ?, 'employee', 0, 1, 16, 0, 16, 1, 1)`,
          [empNo, name, dept, phone, defaultPassword]
        );
        inserted++;
      }
    } catch (err) {
      console.error('Error with emp', empNo, err.message);
      skipped++;
    }
  }

  console.log(`Import complete. Inserted: ${inserted}, Updated: ${updated}, Skipped: ${skipped}`);
  db.end();
}

importData().catch(console.error);
