const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/canteens
// Fetch all canteens with user counts
router.get('/', async (req, res) => {
    try {
        const query = `
            SELECT 
                c.id,
                c.name,
                c.location,
                c.is_active,
                COUNT(u.id) as user_count
            FROM canteens c
            LEFT JOIN users u ON u.canteen_id = c.id
            GROUP BY c.id
            ORDER BY c.name ASC
        `;
        const [rows] = await db.query(query);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching canteens:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
});

// DELETE /api/canteens/:id
// Delete a canteen and map its users to CHQ
router.delete('/:id', async (req, res) => {
    const canteenId = req.params.id;
    const CHQ_PROJECT_ID = 5;
    const CHQ_CANTEEN_ID = 5;

    // Prevent deleting the default CHQ canteen to avoid orphan loops
    if (parseInt(canteenId, 10) === CHQ_CANTEEN_ID) {
        return res.status(400).json({ message: 'Cannot delete the default CHQ canteen.' });
    }

    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Move all users currently mapped to this canteen to CHQ
        const [updateRes] = await connection.query(
            'UPDATE users SET canteen_id = ?, project_id = ? WHERE canteen_id = ?',
            [CHQ_CANTEEN_ID, CHQ_PROJECT_ID, canteenId]
        );

        // 2. Delete the canteen
        const [deleteRes] = await connection.query(
            'DELETE FROM canteens WHERE id = ?',
            [canteenId]
        );

        if (deleteRes.affectedRows === 0) {
            await connection.rollback();
            return res.status(404).json({ message: 'Canteen not found' });
        }

        await connection.commit();
        res.json({ 
            message: 'Canteen deleted successfully',
            usersMoved: updateRes.affectedRows
        });
    } catch (error) {
        await connection.rollback();
        console.error('Error deleting canteen:', error);
        res.status(500).json({ message: 'Failed to delete canteen due to server error' });
    } finally {
        connection.release();
    }
});

module.exports = router;
