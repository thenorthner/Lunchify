require('dotenv').config();
const mysql = require('mysql2/promise');
const xlsx = require('xlsx');

async function revertData() {
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
  
  const empIds = [];
  for (const row of data) {
    const empNo = row['Emp No'] ? String(row['Emp No']).trim() : '';
    if (empNo) {
      empIds.push(empNo);
    }
  }

  if (empIds.length > 0) {
    // Delete only the ones we inserted (which have is_registered = 0)
    // We will do it in chunks if the list is too large, but 1664 is small enough for one query
    const [result] = await db.query(
      'DELETE FROM users WHERE id IN (?) AND is_registered = 0',
      [empIds]
    );
    console.log(`Revert complete. Deleted ${result.affectedRows} newly inserted employees.`);
    
    // For the 2 updated ones, we can just print a warning
    const [remaining] = await db.query(
      'SELECT id, name FROM users WHERE id IN (?)',
      [empIds]
    );
    if (remaining.length > 0) {
      console.log(`Note: ${remaining.length} employees from the Excel file were not deleted because they were already registered before the import. IDs:`, remaining.map(r => r.id).join(', '));
    }
  } else {
    console.log("No valid employee IDs found in Excel to revert.");
  }

  db.end();
}

revertData().catch(console.error);
