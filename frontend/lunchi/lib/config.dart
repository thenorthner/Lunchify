class AppConfig {
  static const String apiBaseUrl = 'http://172.16.16.210:3001';

  // ---------- AUTH ----------
  static String get login => '$apiBaseUrl/api/auth/login';
  static String get register => '$apiBaseUrl/api/auth/register';
  static String checkId(String empId) => '$apiBaseUrl/api/auth/check-id/$empId';
  static String get loginRequest => '$apiBaseUrl/api/auth/login-request';
  static String get verifyOtp => '$apiBaseUrl/api/auth/verify-otp';
  static String get feedbacks => '$apiBaseUrl/api/feedbacks';

  // ---------- MENU ----------
  static String foodMenuByDate(String date) =>
      '$apiBaseUrl/api/menu/food?date=$date';

  static String fruitMenuByDate(String date) =>
      '$apiBaseUrl/api/menu/fruit?date=$date';

  static String get rooms => '$apiBaseUrl/api/rooms';

  static String snacksMenu(String date, String session) =>
      '$apiBaseUrl/api/menu/snacks?date=$date&session=$session';

  static String get snacks => '$apiBaseUrl/api/snacks';

  // ---------- MENU SAVE (ADMIN) ----------
  static String get saveFoodMenu => '$apiBaseUrl/api/menu/food';

  static String get saveFruitMenu => '$apiBaseUrl/api/menu/fruit';

  static String get saveSnacksMenu => '$apiBaseUrl/api/menu/snacks';

  // ---------- QR ----------
  static String get generateQr => '$apiBaseUrl/api/qr/generate-qr';

  // ---------- FRUIT LUNCH ----------
  static String get fruitLunchOrdersDetails =>
      '$apiBaseUrl/api/fruit-lunch/requests';

  // ---------- FOOD LUNCH ----------
  static String get foodLunchOrders => '$apiBaseUrl/api/food-lunch';

  static String get foodLunchOrdersDetails =>
      '$apiBaseUrl/api/food-lunch/requests';

  // ---------- SNACK ORDERS ----------
  static String get snackOrders => '$apiBaseUrl/api/snack-orders';

  // ---------- SNACK ITEMS ----------
  static String get activeSnacksItems => '$apiBaseUrl/api/snacks/active';

  // ---------- COUPONS ----------
  static String get shareCoupons => '$apiBaseUrl/api/coupons/share';
}
