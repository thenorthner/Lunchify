const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config({ path: __dirname + '/.env' });

const app = express();

// Trust proxy is required if the app is behind Nginx/Apache 
// so that express-rate-limit uses the actual client's IP instead of the proxy's IP.
app.set('trust proxy', 1);

/* ===== STARTUP VALIDATION ===== */
if (!process.env.JWT_SECRET) {
  console.error("FATAL ERROR: JWT_SECRET is not defined in environment variables.");
  process.exit(1);
}
if (!process.env.DB_HOST || !process.env.DB_USER || process.env.DB_PASSWORD === undefined || !process.env.DB_NAME) {
  console.error("FATAL ERROR: Database credentials are not fully defined in environment variables.");
  process.exit(1);
}

/* ===== MIDDLEWARE ===== */
app.use(helmet());
const allowedOrigins = process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000', 'http://172.16.16.210:3000'];
app.use(cors({
  origin: function (origin, callback) {
    if (
      !origin ||
      allowedOrigins.indexOf(origin) !== -1 ||
      origin.startsWith('http://localhost:') ||
      origin.startsWith('http://127.0.0.1:')
    ) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));
app.use(express.json());
app.use((req, res, next) => { console.log(`[REQUEST] ${req.method} ${req.url}`); next(); });
const rateLimit = require('express-rate-limit');

/* ===== GLOBAL RATE LIMIT ===== */
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 500, // limit each IP to 500 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', apiLimiter);

/* ===== CSRF MIDDLEWARE ===== */
function requireCsrfHeader(req, res, next) {
  if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method)) {
    // Bypass for auth routes where token is not yet granted
    if (req.originalUrl && req.originalUrl.startsWith('/api/auth/')) {
      return next();
    }
    // If it's a mobile client sending a Bearer token, bypass the check.
    if (req.headers['authorization'] && req.headers['authorization'].startsWith('Bearer')) {
      return next();
    }
    // Otherwise, require the custom header
    if (req.headers['x-requested-with'] !== 'XMLHttpRequest') {
      return res.status(403).json({ message: 'Forbidden: CSRF token missing' });
    }
  }
  next();
}
app.use('/api', requireCsrfHeader);

/* ===== ROUTES ===== */
const loginRoutes = require('./routes/login.routes.js');
const qrRoutes = require('./routes/qr.routes.js');
const menuRoutes = require('./routes/menu.routes.js');
const snackRoutes = require('./routes/snack.routes.js');
const roomRoutes = require('./routes/room.routes.js');
const fruitLunchRoutes = require('./routes/fruitLunch.routes.js');
const foodLunchOrderRoutes = require('./routes/foodLunchOrder.routes.js');
const billingRoutes = require('./routes/billing.routes.js');
const transferRoutes = require('./routes/transfer.routes.js');
const feedbackRoutes = require('./routes/feedback.routes.js');
const couponRoutes = require('./routes/coupon.routes.js');
const itemFeedbackRoutes = require('./routes/item_feedback.routes.js');
const canteenRoutes = require('./routes/canteen.routes.js');
const inspectRoutes = require('./routes/inspect.routes.js');

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
app.use('/api/item-feedbacks', itemFeedbackRoutes);
app.use('/api/snack-catalog', snackRoutes);
app.use('/api/canteens', canteenRoutes);
app.use('/api/inspect', inspectRoutes);

/* ===== HEALTH CHECK ===== */
app.get('/health', (req, res) => {
  res.send('✅ Lunchify backend running');
});

/* ===== SERVE ADMIN PORTAL ===== */
const path = require('path');
const adminPortalPath = path.join(__dirname, '../admin-portal/build');
app.use(express.static(adminPortalPath));

// Fallback all other routes to React router
app.get('/{*splat}', (req, res) => {
  res.sendFile(path.join(adminPortalPath, 'index.html'));
});

/* ===== GLOBAL ERROR HANDLER ===== */
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err);
  const status = err.status || 500;
  const message = process.env.NODE_ENV === 'production' 
    ? 'An internal server error occurred' 
    : err.message;
  res.status(status).json({ success: false, message });
});

/* ===== UDP AUTO-DISCOVERY SERVER ===== */
const dgram = require('dgram');
const udpServer = dgram.createSocket('udp4');
udpServer.on('message', (msg, rinfo) => {
  if (msg.toString() === 'DISCOVER_LUNCHIFY_SERVER') {
    udpServer.send(`LUNCHIFY_SERVER:${PORT}`, rinfo.port, rinfo.address);
  }
});
udpServer.bind(4000, '0.0.0.0', () => {
  console.log('📡 UDP Auto-Discovery listening on port 4000');
});

/* ===== SERVER ===== */
const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 Server running');
  console.log(`👉 Local:   http://localhost:${PORT}`);
  const os = require('os');
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        console.log(`👉 Network: http://${net.address}:${PORT}`);
      }
    }
  }
});
