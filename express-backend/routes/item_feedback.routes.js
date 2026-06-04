const express = require('express');
const router = express.Router();
const mysqlPool = require('../db');

// POST /api/item-feedbacks/daily-items
// Submit ratings for multiple menu items
router.post('/daily-items', async (req, res) => {
  console.log('✅ ITEM-FEEDBACK POST HIT - body:', JSON.stringify(req.body).substring(0, 100));
  const { employee_id, canteen_id, date, items } = req.body;

  if (!employee_id || !canteen_id || !date || !items || !Array.isArray(items)) {
    return res.status(400).json({ error: 'Missing required fields or items is not an array' });
  }

  const connection = await mysqlPool.getConnection();
  try {
    await connection.beginTransaction();

    for (const item of items) {
      const { name, rating, remarks } = item;
      if (!name || typeof rating !== 'number') continue;

      // Upsert to handle updates if the user resubmits on the same day
      await connection.query(
        `INSERT INTO daily_item_feedbacks (employee_id, canteen_id, date, item_name, rating, remarks)
         VALUES (?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE rating = VALUES(rating), remarks = VALUES(remarks)`,
        [employee_id, canteen_id, date, name, rating, remarks || '']
      );
    }

    await connection.commit();
    res.json({ message: 'Feedback submitted successfully' });
  } catch (error) {
    await connection.rollback();
    console.error('Error submitting item feedback:', error);
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    connection.release();
  }
});

// GET /api/feedback/daily-items?date=YYYY-MM-DD&canteen_id=1
// Fetch aggregated ratings for Admin Portal
router.get('/daily-items', async (req, res) => {
  const { date, canteen_id } = req.query;

  if (!date) {
    return res.status(400).json({ error: 'Date is required' });
  }

  try {
    let query = `
      SELECT 
        item_name, 
        AVG(rating) as average_rating, 
        COUNT(rating) as total_reviews,
        GROUP_CONCAT(remarks SEPARATOR '||') as all_remarks
      FROM daily_item_feedbacks
      WHERE date = ?
    `;
    const params = [date];

    if (canteen_id) {
      query += ` AND canteen_id = ?`;
      params.push(canteen_id);
    }

    query += ` GROUP BY item_name`;

    const [rows] = await mysqlPool.query(query, params);

    // Parse the remarks string into an array, filtering out empties
    const formattedRows = rows.map(row => {
      const remarksList = row.all_remarks 
        ? row.all_remarks.split('||').map(r => r.trim()).filter(r => r.length > 0)
        : [];
      return {
        item_name: row.item_name,
        average_rating: parseFloat(Number(row.average_rating).toFixed(1)),
        total_reviews: row.total_reviews,
        remarks: remarksList
      };
    });

    res.json(formattedRows);
  } catch (error) {
    console.error('Error fetching item feedback:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
