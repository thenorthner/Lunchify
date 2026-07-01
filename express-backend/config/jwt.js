// Centralized JWT configuration and Token Blacklist
const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
  console.error("FATAL ERROR: JWT_SECRET is not defined.");
  process.exit(1);
}

module.exports = {
  JWT_SECRET,
  USER_TOKEN_EXPIRY: '8h',
  ADMIN_TOKEN_EXPIRY: '24h'
};
