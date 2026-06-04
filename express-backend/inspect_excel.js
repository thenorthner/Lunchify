const xlsx = require('xlsx');

// Path to the Excel file
const filePath = '../Employee master data.xlsx';

// Read the file
const workbook = xlsx.readFile(filePath);
const sheetName = workbook.SheetNames[0];
const sheet = workbook.Sheets[sheetName];

// Convert to JSON
const data = xlsx.utils.sheet_to_json(sheet);

// Print the first 2 rows
console.log("Total records:", data.length);
console.log("First 2 rows:", JSON.stringify(data.slice(0, 2), null, 2));
