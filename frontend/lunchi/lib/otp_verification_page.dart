import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';
import 'config.dart';

class OTPVerificationPage extends StatefulWidget {
  final String empId;
  final String phone;
  final String password;

  const OTPVerificationPage({
    super.key,
    required this.empId,
    required this.phone,
    required this.password,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  static const sjvnBlue = Color(0xFF0A4DA2);
  static const sjvnLightBlue = Color(0xFFE8F0FF);

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      _show("Enter valid 6-digit OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "employeeId": widget.empId,
          "phone": widget.phone,
          "otp": otp,
          "password": widget.password,
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 &&
          (body['success'] == true || body['verified'] == true || body['message'] == 'Account created successfully')) {
        // ✅ OTP VERIFIED → GO TO LOGIN
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created successfully! Please login."),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      } else {
        _show(body['message'] ?? "Invalid OTP");
      }
    } catch (_) {
      _show("Cannot reach server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sjvnBlue,
        title: const Text("OTP Verification"),
      ),
      body: Container(
        color: sjvnLightBlue,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 60, color: sjvnBlue),
            const SizedBox(height: 20),

            Text(
              "Enter OTP",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: sjvnBlue,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "OTP sent to ${widget.phone}",
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: "",
                hintText: "••••••",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sjvnBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading ? null : _verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
