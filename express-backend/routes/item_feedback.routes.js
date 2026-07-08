const express = require('express');
const router = express.Router();
const mysqlPool = require('../db');
const { requireAuth } = require('../middleware/auth.middleware');

router.use(requireAuth);

router.post('/daily-items', async (req, res) => {
  console.log('✅ ITEM-FEEDBACK POST HIT - body:', JSON.stringify(req.body).substring(0, 100));
  const { employee_id, date, items } = req.body;
  
  const effectiveCanteenId = req.user.role === 'employee' ? req.user.canteen_id : (req.body.canteen_id || req.user.canteen_id);

  if (req.user.role === 'canteen_admin' && Number(effectiveCanteenId) !== Number(req.user.canteen_id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  // BOLA check: standard employee can only submit feedback for themselves
  if (req.user.role === 'employee' && employee_id !== req.user.id) {
    return res.status(403).json({ error: 'Access denied. You can only submit feedback for yourself.' });
  }

  if (!employee_id || !effectiveCanteenId || !date || !items || !Array.isArray(items)) {
    return res.status(400).json({ error: 'Missing required fields or items is not an array' });
  }

  if (items.length > 50) {
    return res.status(400).json({ error: 'Too many items in feedback' });
  }

  const connection = await mysqlPool.getConnection();
  try {
    await connection.beginTransaction();

    for (const item of items) {
      const { name, rating, remarks } = item;
      if (!name || typeof rating !== 'number' || rating < 1 || rating > 5) continue;

      let safeRemarks = remarks || '';
      if (typeof safeRemarks === 'string' && safeRemarks.length > 500) {
        safeRemarks = safeRemarks.substring(0, 500);
      }

      // Upsert to handle updates if the user resubmits on the same day
      await connection.query(
        `INSERT INTO daily_item_feedbacks (employee_id, canteen_id, date, item_name, rating, remarks)
          VALUES (?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE rating = VALUES(rating), remarks = VALUES(remarks)`,
        [employee_id, effectiveCanteenId, date, name, rating, safeRemarks]
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

// GET /api/item-feedbacks/check-today
// Check if current user has already submitted feedback for a specific date
router.get('/check-today', async (req, res) => {
  try {
    const { date } = req.query;
    if (!date) {
      return res.status(400).json({ error: 'Date is required' });
    }
    const [rows] = await mysqlPool.query(
      "SELECT id FROM daily_item_feedbacks WHERE employee_id = ? AND date = ? LIMIT 1",
      [req.user.id, date]
    );
    res.json({ has_rated: rows.length > 0 });
  } catch (error) {
    console.error('Error checking feedback status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/feedback/daily-items?date=YYYY-MM-DD&canteen_id=1
// Fetch aggregated ratings for Admin Portal
router.get('/daily-items', async (req, res) => {
  // BOLA Check: Only admins should read aggregated feedback
  if (!['canteen_admin', 'it_admin', 'hr_admin'].includes(req.user.role)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  const { date } = req.query;
  
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

    if (req.user.role === 'canteen_admin') {
      query += ` AND canteen_id = ?`;
      params.push(req.user.canteen_id);
    } else if (req.user.role === 'it_admin' || req.user.role === 'hr_admin') {
      if (!req.query.canteen_id) {
        return res.status(400).json({ error: 'canteen_id is required' });
      }
      
      if (req.user.role === 'hr_admin') {
         const [canteenCheck] = await mysqlPool.query("SELECT project_id FROM canteens WHERE id = ?", [req.query.canteen_id]);
         if (canteenCheck.length === 0 || canteenCheck[0].project_id !== req.user.project_id) {
            return res.status(403).json({ error: 'Access denied: project mismatch' });
         }
      }

      query += ` AND canteen_id = ?`;
      params.push(req.query.canteen_id);
    } else {
      return res.status(403).json({ error: 'Access denied' });
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
