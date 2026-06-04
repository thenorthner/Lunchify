const xlsx = require('xlsx');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: __dirname + '/.env' });
const path = require('path');

async function importData() {
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

    console.log('Adding missing columns if they don\'t exist...');
    
    // Check if columns exist
    const [columns] = await pool.query('SHOW COLUMNS FROM users');
    const colNames = columns.map(c => c.Field);
    
    if (!colNames.includes('email')) {
      await pool.query('ALTER TABLE users ADD COLUMN email VARCHAR(255)');
    }
    if (!colNames.includes('designation')) {
      await pool.query('ALTER TABLE users ADD COLUMN designation VARCHAR(255)');
    }
    if (!colNames.includes('location')) {
      await pool.query('ALTER TABLE users ADD COLUMN location VARCHAR(255)');
    }

    const filePath = path.join(__dirname, '..', 'EMP_details.xlsx');
    console.log('Reading Excel file:', filePath);
    
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[sheetName];
    const data = xlsx.utils.sheet_to_json(sheet);

    console.log(`Found ${data.length} records. Starting import...`);

    let imported = 0;
    let skipped = 0;

    for (const row of data) {
      const empId = row['Emp id']?.toString().trim();
      const name = row['Name']?.toString().trim() || 'Unknown';
      const designation = row['Designation']?.toString().trim() || null;
      const department = row['Department']?.toString().trim() || null;
      const location = row['Location']?.toString().trim() || null;
      const phone = row['Contact No1']?.toString().trim() || null;
      const email = row['Email']?.toString().trim() || null;

      if (!empId) {
        skipped++;
        continue;
      }

      // Check if exists
      const [existing] = await pool.query('SELECT id FROM users WHERE id = ?', [empId]);
      
      if (existing.length > 0) {
        // Update
        await pool.query(
          `UPDATE users SET name = ?, designation = ?, department = ?, location = ?, phone = ?, email = ? WHERE id = ?`,
          [name, designation, department, location, phone, email, empId]
        );
      } else {
        // Insert
        await pool.query(
          `INSERT INTO users (id, name, designation, department, location, phone, email, is_registered, role, coupons_left, coupons_used, monthly_limit) 
           VALUES (?, ?, ?, ?, ?, ?, ?, 0, 'employee', 16, 0, 16)`,
          [empId, name, designation, department, location, phone, email]
        );
      }
      imported++;
    }

    console.log(`Import complete! Imported/Updated: ${imported}. Skipped (No ID): ${skipped}.`);
  } catch (err) {
    console.error('Error importing data:', err);
  } finally {
    if (pool) await pool.end();
  }
}

importData();
