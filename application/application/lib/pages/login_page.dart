import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─── Colors ───────────────────────────────────────────────────────────────────
const kNavy   = Color(0xFF1A2E6E);
const kBlue   = Color(0xFF1E5CBF);
const kSky    = Color(0xFF3A8DE0);
const kRed    = Color(0xFFE02020);
const kPale   = Color(0xFFEDF4FC);
const kSubtle = Color(0xFFF0F5FB);
const kGray   = Color(0xFF8A96A8);
const kBorder = Color(0xFFDCE8F5);

// ─── Login Screen ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _empCtrl  = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure   = true;
  bool _loading   = false;
  bool _success   = false;

  late AnimationController _pulseCtrl;
  late AnimationController _cardCtrl;
  late Animation<double>   _cardAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic);
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _cardCtrl.dispose();
    _empCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() { _loading = true; _success = false; });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() { _loading = false; _success = true; });
    await Future.delayed(const Duration(milliseconds: 1000));
    // ✅ Navigate to home and remove login from back stack
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC5D9EF), Color(0xFFD8E9F7), Color(0xFFBCD2E9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: FadeTransition(
                opacity: _cardAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(_cardAnim),
                  child: Container(
                    width: 420,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.93),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: kNavy.withOpacity(0.18),
                          blurRadius: 60,
                          offset: const Offset(0, 24),
                        ),
                        BoxShadow(
                          color: kNavy.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeroSection(pulseCtrl: _pulseCtrl),
                          _FormSection(
                            empCtrl:    _empCtrl,
                            passCtrl:   _passCtrl,
                            obscure:    _obscure,
                            loading:    _loading,
                            success:    _success,
                            onToggle:   () => setState(() => _obscure = !_obscure),
                            onLogin:    _handleLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _HeroSection({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F2FB), Color(0xFFC8DFF5)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/images/sjvn_scene.png',
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0, right: 0,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/lunchify_logo.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.lunch_dining,
                        size: 100,
                        color: kBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final TextEditingController empCtrl, passCtrl;
  final bool obscure, loading, success;
  final VoidCallback onToggle, onLogin;

  const _FormSection({
    required this.empCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.success,
    required this.onToggle,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -35),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Login to your SJVN account to continue',
                style: TextStyle(
                  fontSize: 13.5,
                  color: kGray,
                ),
              ),

              const SizedBox(height: 20),

              _InputField(
                controller: empCtrl,
                hint: 'Employee ID',
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 12),

              _InputField(
                controller: passCtrl,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: kGray,
                    size: 20,
                  ),
                  onPressed: onToggle,
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: success
                          ? [const Color(0xFF1A7A4E), const Color(0xFF22A66A)]
                          : loading
                              ? [kBlue, kSky]
                              : [kNavy, kBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kNavy.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: loading || success ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                success ? 'Success!' : 'Login',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                success
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0EAF5))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'New to Lunchify?',
                      style: TextStyle(fontSize: 12.5, color: kGray),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0EAF5))),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_outlined, color: kNavy, size: 17),
                  label: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: kNavy,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC8D9ED), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: kSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: kBlue.withOpacity(0.7), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Secure access for SJVN employees only.\nYour data is safe with us.',
                        style: TextStyle(fontSize: 12, color: kGray, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Input Field ──────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14.5, color: Color(0xFF1A2340)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BFCC), fontSize: 14.5),
        prefixIcon: Icon(icon, color: const Color(0xFF9BB0CC), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: kSubtle,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBlue, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Mountain Painter ─────────────────────────────────────────────────────────
class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final farPaint = Paint()
      ..color = const Color(0xFFB8D1E8).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final farPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.62)
      ..lineTo(w * 0.10, h * 0.38)
      ..lineTo(w * 0.19, h * 0.54)
      ..lineTo(w * 0.31, h * 0.23)
      ..lineTo(w * 0.43, h * 0.50)
      ..lineTo(w * 0.55, h * 0.31)
      ..lineTo(w * 0.67, h * 0.46)
      ..lineTo(w * 0.76, h * 0.27)
      ..lineTo(w * 0.90, h * 0.54)
      ..lineTo(w, h * 0.38)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(farPath, farPaint);

    final nearPaint = Paint()
      ..color = const Color(0xFF9CBFE0).withOpacity(0.65)
      ..style = PaintingStyle.fill;
    final nearPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.73)
      ..lineTo(w * 0.14, h * 0.46)
      ..lineTo(w * 0.29, h * 0.69)
      ..lineTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.64, h * 0.62)
      ..lineTo(w * 0.81, h * 0.42)
      ..lineTo(w, h * 0.65)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(nearPath, nearPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
