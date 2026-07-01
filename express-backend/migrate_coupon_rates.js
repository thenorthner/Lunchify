const { mysqlPool } = require('./db');

async function migrate() {
  const conn = await mysqlPool.getConnection();
  try {
    console.log('Creating coupon_rates table...');
    await conn.query(`
      CREATE TABLE IF NOT EXISTS coupon_rates (
        id INT AUTO_INCREMENT PRIMARY KEY,
        canteen_id INT NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        effective_from DATE NOT NULL,
        effective_to DATE NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (canteen_id) REFERENCES canteens(id) ON DELETE CASCADE
      )
    `);

    // Insert a default rate for all existing canteens if not exists
    const [canteens] = await conn.query('SELECT id FROM canteens');
    for (const canteen of canteens) {
      const [existing] = await conn.query('SELECT id FROM coupon_rates WHERE canteen_id = ?', [canteen.id]);
      if (existing.length === 0) {
        await conn.query(
          'INSERT INTO coupon_rates (canteen_id, unit_price, effective_from) VALUES (?, ?, ?)',
          [canteen.id, 50.00, '2023-01-01']
        );
      }
    }
    
    console.log('Migration completed successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  } finally {
    conn.release();
  }
}

migrate();
