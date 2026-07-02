const express = require('express');
const router = express.Router();
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');
const { mysqlPool } = require('../db');

router.post('/generate-qr', async (req, res) => {
    console.log("📥 Incoming Request Body:", req.body);

    const { employeeId, type, date } = req.body;

    if (!employeeId || !type || !date) {
        return res.status(400).json({
            success: false,
            message: 'Missing employeeId, type, or date',
            received: req.body 
        });
    }

    try {
        const qrId = uuidv4();
        const token = `QR_${qrId}|${employeeId}|${type}|${date}`;
        const expiresAt = new Date(Date.now() + 3600000); // 1 Hour Expiry

        await mysqlPool.query(
            "INSERT INTO food_lunch_qr_tokens (employee_id, token, expires_at) VALUES (?, ?, ?)",
            [employeeId, token, expiresAt]
        );

        const qrImage = await QRCode.toDataURL(token);

        res.json({
            success: true,
            qrData: token,
            qrImage: qrImage,
            expiresAt: expiresAt.toISOString()
        });
    } catch (err) {
        console.error("❌ Database Error:", err);
        res.status(500).json({ success: false, error: err.message });
    }
});

module.exports = router;