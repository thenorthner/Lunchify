const express = require('express');
const cors = require('cors');
require('dotenv').config({ path: __dirname + '/.env' });

const app = express();

/* ===== MIDDLEWARE ===== */
app.use(cors({ origin: '*' }));
app.use(express.json());

/* ===== ROUTES ===== */
const loginRoutes = require('./routes/login.routes.js');
const qrRoutes = require('./routes/qr.routes.js');
const menuRoutes = require('./routes/menu.routes.js');
const snackRoutes = require('./routes/snack.routes.js');
const roomRoutes = require('./routes/room.routes.js');
const fruitLunchRoutes = require('./routes/fruitLunch.routes.js');
const snackOrderRoutes = require('./routes/snackOrder.routes.js');
const foodLunchOrderRoutes = require('./routes/foodLunchOrder.routes.js');
const billingRoutes = require('./routes/billing.routes.js');
const transferRoutes = require('./routes/transfer.routes.js');
const feedbackRoutes = require('./routes/feedback.routes.js');
const couponRoutes = require('./routes/coupon.routes.js');

/* ===== USE ROUTES ===== */
app.use('/api/auth', loginRoutes);
app.use('/api/qr', qrRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/snacks', snackRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/fruit-lunch', fruitLunchRoutes);
app.use('/api/fruit-lunch-orders', fruitLunchRoutes);
app.use('/api/snack-orders', snackRoutes);
app.use('/api/food-lunch', foodLunchOrderRoutes);
app.use('/api/food-lunch-orders', foodLunchOrderRoutes);
app.use('/api/billing', billingRoutes);
app.use('/api/transfer', transferRoutes);
app.use('/api/feedbacks', feedbackRoutes);
app.use('/api/coupons', couponRoutes);
app.use('/api', snackRoutes);

/* ===== HEALTH CHECK ===== */
app.get('/', (req, res) => {
  res.send('✅ Lunchify backend running');
});

/* ===== SERVER ===== */
const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 Server running');
  console.log(`👉 Local:   http://localhost:${PORT}`);
  console.log(`👉 Network: http://172.16.19.193:${PORT}`);
});
