//auth.service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AuthService {
  static String? token;
  static Map<String, dynamic>? user;

  static bool get isLoggedIn => token != null && user != null;

  static bool get isAdmin =>
      user != null && (user!['is_admin'] == 1 || user!['is_admin'] == true || user!['role'] == 'it_admin' || user!['role'] == 'hr_admin' || user!['role'] == 'canteen_admin');

  static bool get isITAdmin =>
      user != null && user!['role'] == 'it_admin';

  static String get name => user?['name'] ?? '';
  static String get employeeId => user?['id'] ?? user?['employee_id'] ?? '';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');
    if (userJson != null) {
      try {
        user = Map<String, dynamic>.from(jsonDecode(userJson));
      } catch (e) {
        debugPrint("❌ Error parsing stored user: $e");
      }
    }
  }

  static Future<void> saveSession(String newToken, Map<String, dynamic> newUser) async {
    token = newToken;
    user = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);
    await prefs.setString('auth_user', jsonEncode(newUser));
  }

  static Future<void> clearSession() async {
    token = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }

  static void logout() {
    token = null;
    user = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
      prefs.remove('auth_user');
    });
  }

  // ✅ SAFE JSON OBJECT DECODER
  static Map<String, dynamic> _decodeMapOrThrow(http.Response res, {String? hint}) {
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    final raw = res.body;
    final trimmed = raw.trimLeft();
    final preview = raw.substring(0, raw.length > 350 ? 350 : raw.length);

    debugPrint('$hint STATUS: ${res.statusCode}');
    debugPrint('$hint CONTENT-TYPE: $ct');
    debugPrint('$hint BODY(0..350): $preview');

    if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<html') || trimmed.startsWith('<')) {
      throw Exception('$hint returned HTML (not JSON). HTTP ${res.statusCode}.');
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('$hint Expected JSON object but got ${decoded.runtimeType}');
  }

  static Future<Map<String, dynamic>> checkId(String employeeId) async {
    final url = Uri.parse(AppConfig.checkId(employeeId));
    final response = await http.get(url, headers: const {'Accept': 'application/json'});

    final data = _decodeMapOrThrow(response, hint: 'CHECK-ID');

    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Check ID failed');
  }

  static Future<void> requestOtp({
    required String employeeId,
    required String phone,
  }) async {
    final url = Uri.parse(AppConfig.loginRequest);

    final response = await http.post(
      url,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'employeeId': employeeId.trim().toUpperCase(),
        'phone': phone,
      }),
    );

    final data = _decodeMapOrThrow(response, hint: 'OTP');

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'OTP request failed');
    }
  }

  static Future<void> verifyOtp({
    required String employeeId,
    required String phone,
    required String otp,
    required String password,
  }) async {
    final url = Uri.parse(AppConfig.verifyOtp);

    final response = await http.post(
      url,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'employeeId': employeeId.trim().toUpperCase(),
        'phone': phone,
        'otp': otp,
        'password': password,
      }),
    );

    final data = _decodeMapOrThrow(response, hint: 'VERIFY-OTP');

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'OTP verification failed');
    }
  }

  static Future<void> login({
    required String employeeId,
    required String password,
  }) async {
    final url = Uri.parse(AppConfig.login);

    final response = await http.post(
      url,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'employeeId': employeeId.trim().toUpperCase(),
        'password': password,
      }),
    );

    final data = _decodeMapOrThrow(response, hint: 'LOGIN');

    if (response.statusCode == 200) {
      token = data['token'];
      user = (data['user'] is Map) ? Map<String, dynamic>.from(data['user']) : null;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
}