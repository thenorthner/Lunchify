//auth.service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'network/secure_client.dart';

const storage = FlutterSecureStorage();

class AuthService {
  static String? token;
  static Map<String, dynamic>? user;

  static bool get isLoggedIn => token != null && user != null;

  static bool get isAdmin =>
      user != null && (user!['is_admin'] == 1 || user!['is_admin'] == true || user!['role'] == 'it_admin' || user!['role'] == 'hr_admin' || user!['role'] == 'canteen_admin' || user!['role'] == 'scanner');

  static bool get isITAdmin =>
      user != null && user!['role'] == 'it_admin';

  static String get name => user?['name'] ?? '';
  static String get employeeId => user?['id'] ?? user?['employee_id'] ?? '';

  static Future<void> init() async {
    token = await storage.read(key: 'auth_token');
    final userJson = await storage.read(key: 'auth_user');
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
    await storage.write(key: 'auth_token', value: newToken);
    await storage.write(key: 'auth_user', value: jsonEncode(newUser));
  }

  static Future<void> clearSession() async {
    token = null;
    user = null;
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'auth_user');
  }

  static void logout() {
    token = null;
    user = null;
    storage.delete(key: 'auth_token');
    storage.delete(key: 'auth_user');
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
    final client = SecureClient.getClient();
    final response = await client.get(url, headers: const {'Accept': 'application/json'});

    final data = _decodeMapOrThrow(response, hint: 'CHECK-ID');

    if (response.statusCode == 200) return data;
    if (response.statusCode == 400 && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? 'Check ID failed');
  }

  static Future<void> requestOtp({
    required String employeeId,
    required String phone,
  }) async {
    final url = Uri.parse(AppConfig.loginRequest);
    final client = SecureClient.getClient();

    final response = await client.post(
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
    final client = SecureClient.getClient();

    final response = await client.post(
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
    final client = SecureClient.getClient();

    final response = await client.post(
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
