import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'app_theme.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kNavy    = Color(0xFF1A2E6E);
const _kAccent  = Color(0xFF2563EB);
const _kBg      = Color(0xFFEAF2FF);
const _kCard    = Color(0xFFFFFFFF);
const _kLight   = Color(0xFFDBE9FF);
const _kSubtext = Color(0xFF8A96A8);
const _kBorder  = Color(0xFFDCE8F5);
const _kFill    = Color(0xFFF0F5FB);

// ════════════════════════════════════════════════════════════════════════════
//  RESET PASSWORD PAGE
// ════════════════════════════════════════════════════════════════════════════
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _empIdCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool  _loading    = false;
  bool  _otpSent    = false;

  late final AnimationController _cardCtrl;
  late final Animation<double>   _cardAnim;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic);
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _empIdCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Send verification code via SMS ────────────────────────────────────────
  Future<void> _sendCode() async {
    final empId = _empIdCtrl.text.trim().toUpperCase();
    final phone = _phoneCtrl.text.trim();
    if (empId.isEmpty || phone.isEmpty) {
      _showSnack('Please fill in all fields.', isError: true);
      return;
    }
    if (phone.length < 10) {
      _showSnack('Enter a valid 10-digit phone number.', isError: true);
      return;
    }
    
    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': empId,
          'phone': phone,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _otpSent = true;
          _loading = false;
        });
        _showSnack("Verification code sent to your registered mobile number!");
      } else {
        final error = body['message'] ?? 'Failed to send OTP.';
        _showSnack(error, isError: true);
        setState(() => _loading = false);
      }
    } catch (e) {
      _showSnack("Error connecting to server: $e", isError: true);
      setState(() => _loading = false);
    }
  }

  // ── Reset Password ─────────────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    final empId = _empIdCtrl.text.trim().toUpperCase();
    final phone = _phoneCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      _showSnack("Please enter a valid 6-digit OTP.", isError: true);
      return;
    }
    if (newPass.isEmpty || newPass.length < 4) {
      _showSnack("Password must be at least 4 characters.", isError: true);
      return;
    }
    if (newPass != confirmPass) {
      _showSnack("Passwords do not match.", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': empId,
          'phone': phone,
          'otp': otp,
          'newPassword': newPass,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => _loading = false);
        _showSnack("Password reset successfully! Please login with your new password.");
        if (mounted) Navigator.pop(context);
      } else {
        final error = body['message'] ?? 'Failed to reset password.';
        _showSnack(error, isError: true);
        setState(() => _loading = false);
      }
    } catch (e) {
      _showSnack("Error connecting to server: $e", isError: true);
      setState(() => _loading = false);
    }
  }

  // ── Send code via email ───────────────────────────────────────────────────
  void _sendEmail() {
    if (_empIdCtrl.text.trim().isEmpty) {
      _showSnack('Please enter your Employee ID first.', isError: true);
      return;
    }
    _showSnack('Verification code sent to your registered email!');
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFE02020) : _kNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildRequestOtpForm() {
    return Column(
      children: [
        // ── Lock reset icon ───────────────────────
        _LockIcon(),
        const SizedBox(height: 20),
        
        // ── Title ─────────────────────────────────
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: _kNavy,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        
        const Text(
          'Enter your registered Employee ID and Phone\nNumber to verify your account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: _kSubtext,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        
        // ── Employee ID field ─────────────────────
        _InputField(
          controller: _empIdCtrl,
          hint: 'Employee ID',
          icon: Icons.badge_outlined,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
        ),
        const SizedBox(height: 14),
        
        // ── Phone Number field ────────────────────
        _InputField(
          controller: _phoneCtrl,
          hint: 'Phone Number',
          icon: Icons.phone_outlined,
          inputType: TextInputType.phone,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 24),
        
        // ── Send Verification Code button ─────────
        _PrimaryButton(
          loading: _loading,
          label: 'Send Verification Code',
          icon: Icons.send_rounded,
          onTap: _sendCode,
        ),
        const SizedBox(height: 20),
        
        // ── OR divider ────────────────────────────
        Row(
          children: const [
            Expanded(child: Divider(color: Color(0xFFE0EAF5))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kSubtext,
                ),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFE0EAF5))),
          ],
        ),
        const SizedBox(height: 20),
        
        // ── Send Code via Email button ────────────
        _OutlineButton(
          label: 'Send Code via Email',
          icon: Icons.email_outlined,
          onTap: _sendEmail,
        ),
        const SizedBox(height: 20),
        
        // ── Back to Login link ────────────────────
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.chevron_left_rounded,
                color: _kAccent, size: 20,
              ),
              Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _kAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      children: [
        _LockIcon(),
        const SizedBox(height: 20),
        
        const Text(
          'Enter Verification Code',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: _kNavy,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        
        Text(
          'We sent a 6-digit OTP code to ${_phoneCtrl.text.trim()}.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            color: _kSubtext,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        
        _InputField(
          controller: _otpCtrl,
          hint: '6-Digit OTP',
          icon: Icons.vpn_key_outlined,
          inputType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        const SizedBox(height: 14),
        
        _InputField(
          controller: _newPassCtrl,
          hint: 'New Password',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 14),
        
        _InputField(
          controller: _confirmPassCtrl,
          hint: 'Confirm New Password',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 24),
        
        _PrimaryButton(
          loading: _loading,
          label: 'Reset Password',
          icon: Icons.security_rounded,
          onTap: _resetPassword,
        ),
        const SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _otpSent = false;
                  _otpCtrl.clear();
                  _newPassCtrl.clear();
                  _confirmPassCtrl.clear();
                });
              },
              child: const Text("Edit Phone", style: TextStyle(color: _kSubtext, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: _sendCode,
              child: const Text("Resend OTP", style: TextStyle(color: _kAccent, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Full page scrollable content ──────────────────────────────
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── Top area with bg image + back button ─────────────
                  _TopSection(),

                  // ── Card ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: FadeTransition(
                      opacity: _cardAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(_cardAnim),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _kCard,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: _kNavy.withOpacity(0.10),
                                blurRadius: 32,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                          child: AnimatedCrossFade(
                            firstChild: _buildRequestOtpForm(),
                            secondChild: _buildResetPasswordForm(),
                            crossFadeState: _otpSent ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 400),
                            alignment: Alignment.topCenter,
                            sizeCurve: Curves.easeInOutBack,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Security note ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: _kAccent, size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'For security reasons, we will send a verification code to your registered mobile number or email.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: _kSubtext,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Section (bg image + back button) ────────────────────────────────────
class _TopSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD0DCF0), Color(0xFFBFD3EA)],
                  ),
                ),
              ),
            ),
          ),

          // Soft gradient fade over image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6, 1.0],
                  colors: [
                    Color(0x44EAF2FF),
                    Color(0x88EAF2FF),
                    Color(0xFFEAF2FF),
                  ],
                ),
              ),
            ),
          ),

          // Back button top-left
          Positioned(
            top: 12, left: 12,
            child: _BackButton(),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Back Button ─────────────────────────────────────────────────────
class _BackButton extends StatefulWidget {
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<double>(begin: 0, end: -4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit:  (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(_slide.value, 0.0)
              ..scale(_scale.value),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kNavy.withOpacity(0.12),
                    blurRadius: 10, offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: _kNavy, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Lock Reset Icon ─────────────────────────────────────────────────
class _LockIcon extends StatefulWidget {
  @override
  State<_LockIcon> createState() => _LockIconState();
}

class _LockIconState extends State<_LockIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _rotate = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: const BoxDecoration(
        color: _kLight, shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating arc
          AnimatedBuilder(
            animation: _rotate,
            builder: (_, __) => Transform.rotate(
              angle: _rotate.value * 2 * 3.14159,
              child: CustomPaint(
                size: const Size(54, 54),
                painter: _ArcPainter(),
              ),
            ),
          ),
          // Lock icon in center
          const Icon(Icons.lock_outline_rounded, color: _kAccent, size: 28),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw ~270° arc (open at bottom-right)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -1.57, // start at top
      4.71,  // ~270 degrees
      false,
      paint,
    );

    // Arrowhead at the end of the arc
    final arrowPaint = Paint()
      ..color = _kAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height;
    canvas.drawLine(
      Offset(cx, cy - 6),
      Offset(cx + 6, cy),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(cx + 6, cy),
      Offset(cx + 12, cy - 6),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType inputType;
  final List<TextInputFormatter>? formatters;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.inputType = TextInputType.text,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatters,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14.5, color: Color(0xFF1A2340)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BFCC), fontSize: 14.5),
        prefixIcon: Icon(icon, color: const Color(0xFF9BB0CC), size: 20),
        filled: true,
        fillColor: _kFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16, horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kAccent, width: 1.8),
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final bool loading;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.loading,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A2E6E), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2E6E).withOpacity(0.32),
                blurRadius: 18, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.loading
              ? const Center(
                  child: SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────
class _OutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: _pressed ? _kLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder, width: 1.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: _kAccent, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _kAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
