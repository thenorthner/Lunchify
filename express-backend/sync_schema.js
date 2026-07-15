const fs = require('fs');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function syncSchema() {
  console.log('🔄 Syncing schema.sql with Aiven Cloud DB (without losing data)...');
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      ssl: { rejectUnauthorized: false }
    });

    const schema = fs.readFileSync('schema.sql', 'utf8');

    // Simple parser to extract CREATE TABLE blocks
    const tableRegex = /CREATE TABLE `?([a-zA-Z0-9_]+)`?\s*\(([\s\S]*?)\)(?:\s*ENGINE=[^\;]+)?\;/g;
    
    let match;
    while ((match = tableRegex.exec(schema)) !== null) {
      const tableName = match[1];
      const tableBody = match[2];

      // Check if table exists
      const [tableExists] = await connection.query(`SHOW TABLES LIKE '${tableName}'`);
      
      if (tableExists.length === 0) {
        // Table doesn't exist, create it fully
        console.log(`📦 Creating missing table: ${tableName}`);
        const createQuery = match[0];
        await connection.query(createQuery);
        continue;
      }

      // If table exists, parse its columns from schema.sql
      // Split by comma but ignore commas inside parentheses (e.g. enum('a','b') or decimal(10,2))
      const lines = tableBody.split(/,\n/).map(l => l.trim()).filter(l => l);
      
      const schemaColumns = [];
      for (const line of lines) {
        if (line.startsWith('PRIMARY KEY') || line.startsWith('UNIQUE KEY') || line.startsWith('KEY') || line.startsWith('CONSTRAINT')) {
          continue; // Skip keys and constraints for now
        }
        
        // Extract column name and definition
        // Example: `name` varchar(255) NOT NULL
        const colMatch = line.match(/^`([a-zA-Z0-9_]+)`\s+(.*)$/);
        if (colMatch) {
          schemaColumns.push({
            name: colMatch[1],
            definition: colMatch[2]
          });
        }
      }

      // Get existing columns from DB
      const [dbColumnsRows] = await connection.query(`SHOW COLUMNS FROM \`${tableName}\``);
      const dbColumnNames = dbColumnsRows.map(row => row.Field);

      // Compare and find missing columns
      for (const schemaCol of schemaColumns) {
        if (!dbColumnNames.includes(schemaCol.name)) {
          console.log(`⚠️ Missing column detected: \`${tableName}\`.\`${schemaCol.name}\``);
          const alterQuery = `ALTER TABLE \`${tableName}\` ADD COLUMN \`${schemaCol.name}\` ${schemaCol.definition}`;
          console.log(`   Executing: ${alterQuery}`);
          try {
            await connection.query(alterQuery);
            console.log(`   ✅ Successfully added column \`${schemaCol.name}\` to \`${tableName}\``);
          } catch (alterErr) {
            console.error(`   ❌ Failed to add column \`${schemaCol.name}\`:`, alterErr.message);
          }
        }
      }
    }

    console.log('🎉 Schema sync completed successfully!');
    await connection.end();
  } catch (error) {
    console.error('❌ Error syncing schema:', error);
  }
}

syncSchema();
