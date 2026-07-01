import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;

import 'login_page.dart';
import 'config.dart';
import 'widgets/top_bar.dart';

// ═════════════════════════════════════════════
// Colour tokens
// ═════════════════════════════════════════════
abstract class _C {
  static const primary   = Color(0xFF1857D6); // header blue
  static const dark      = Color(0xFF0D1F5C); // dark navy text
  static const bg        = Color(0xFFEAF1FF); // page background
  static const grey      = Color(0xFF7C8AA8);
  static const boxBorder = Color(0xFFD7E0F5);
}

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
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _show(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join('').trim();

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
        _show("Account created successfully! Please login.", isSuccess: true);
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
      backgroundColor: _C.bg,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _OtpHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: _C.primary.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const _LockIconCircle(),
                      const SizedBox(height: 22),
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          color: _C.dark,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We have sent a One Time Password (OTP) to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _C.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call_rounded, color: _C.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            widget.phone,
                            style: const TextStyle(
                              color: _C.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      LayoutBuilder(builder: (context, constraints) {
                        final boxSize = (constraints.maxWidth - 5 * 10) / 6;
                        final clamped = boxSize.clamp(40.0, 56.0);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            return Padding(
                              padding: EdgeInsets.only(right: i == 5 ? 0 : 10),
                              child: _OtpBox(
                                controller: _otpControllers[i],
                                focusNode: _focusNodes[i],
                                size: clamped,
                                autofocus: i == 0,
                                onChanged: (v) => _onChanged(v, i),
                              ),
                            );
                          }),
                        );
                      }),

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A2E6E), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A2E6E).withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _verifyOtp,
                          icon: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLoading ? 'Verifying...' : 'Verify Phone & Continue',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (!isLoading) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ]
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3ECFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.primary.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _C.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Secure. Simple. Smart.',
                              style: TextStyle(color: _C.dark, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(color: _C.grey.withOpacity(0.95), fontSize: 12.5),
                                children: const [
                                  TextSpan(text: 'Lunchify by '),
                                  TextSpan(
                                    text: 'SJVN',
                                    style: TextStyle(color: _C.primary, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Header — SJVN Employee Signup Style
// ═════════════════════════════════════════════
class _OtpHeader extends StatelessWidget {
  const _OtpHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color(0xFFD0DCF0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/sjvn_scene.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD0DCF0), Color(0xFFBFD3EA)],
                  ),
                ),
              ),
            ),
          ),
          // Left-fade gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.45, 0.72, 1.0],
                  colors: [
                    Color(0xFFEAF1FF),
                    Color(0xD0EAF1FF),
                    Color(0x88EAF1FF),
                    Color(0x10EAF1FF),
                  ],
                ),
              ),
            ),
          ),
          // Back button + Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 38),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 10),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.maybePop(context),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0D1F5C), size: 24),
                    ),
                  ),
                ),
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D1F5C),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Lock icon with decorative circle + sparkles/dots
// ═════════════════════════════════════════════
class _LockIconCircle extends StatelessWidget {
  const _LockIconCircle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 8, top: 6, child: _dot(6, _C.boxBorder)),
          Positioned(right: 4, top: 16, child: _sparkle(_C.primary.withOpacity(0.4))),
          Positioned(left: 18, bottom: 4, child: _dot(5, _C.boxBorder)),
          Positioned(right: 18, bottom: 0, child: _dot(6, _C.boxBorder)),
          Positioned(left: 0, bottom: 24, child: _sparkle(_C.primary.withOpacity(0.25))),
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: Color(0xFFE3ECFF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(color: _C.primary, shape: BoxShape.circle),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _sparkle(Color color) => Icon(Icons.auto_awesome_rounded, size: 14, color: color);
}

// ═════════════════════════════════════════════
// Single OTP input box
// ═════════════════════════════════════════════
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double size;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.size,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + 4,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(color: _C.dark, fontSize: 22, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _C.boxBorder, width: 1.4)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _C.boxBorder, width: 1.4)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _C.primary, width: 2)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
