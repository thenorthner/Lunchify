import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'admin_page.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'auth_service.dart';
import 'config.dart';
import 'app_theme.dart';

// ─── Login Screen ─────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
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

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAccountNotFoundDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with red shield
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Little red burst lines
                  Positioned(top: 25, left: 40, child: Transform.rotate(angle: -0.5, child: Container(width: 2, height: 8, color: const Color(0xFFF87171)))),
                  Positioned(top: 40, left: 30, child: Transform.rotate(angle: -1.0, child: Container(width: 2, height: 8, color: const Color(0xFFF87171)))),
                  Positioned(top: 55, left: 40, child: Transform.rotate(angle: -1.5, child: Container(width: 2, height: 8, color: const Color(0xFFF87171)))),
                  
                  Positioned(top: 25, right: 40, child: Transform.rotate(angle: 0.5, child: Container(width: 2, height: 8, color: const Color(0xFFF87171)))),
                  Positioned(top: 40, right: 30, child: Transform.rotate(angle: 1.0, child: Container(width: 2, height: 8, color: const Color(0xFFF87171)))),
                  Positioned(top: 55, right: 40, child: Transform.rotate(angle: 1.5, child: Container(width: 2, height: 8, color: const Color(0xFFF87171)))),
                  
                  // Main circle
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFEE2E2).withOpacity(0.8),
                    ),
                    child: Center(
                      child: Container(
                        width: 56, height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF87171), // Red shield color
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.gpp_bad_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Account Not Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A), // kNavy
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This account is not registered\nwith Lunchify.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please sign up first to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            // Go to Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Go to Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final employeeId = _empCtrl.text.trim().toUpperCase();
    final password = _passCtrl.text.trim();

    if (employeeId.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() { _loading = true; _success = false; });

    try {
      final uri = Uri.parse(AppConfig.login);

      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'employeeId': employeeId,
          'employee_id': employeeId,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final bodyText = utf8.decode(response.bodyBytes);
      final trimmed = bodyText.trimLeft();
      if (trimmed.startsWith('<!DOCTYPE') ||
          trimmed.startsWith('<html') ||
          trimmed.startsWith('<')) {
        final head = trimmed.substring(0, trimmed.length > 120 ? 120 : trimmed.length);
        _showError("HTML received. Wrong API URL. Head: $head");
        return;
      }

      dynamic data;
      try {
        data = jsonDecode(bodyText);
      } on FormatException catch (e) {
        _showError("Invalid JSON from server: $e");
        return;
      }

      if (response.statusCode == 200) {
        final token = (data is Map ? data['token'] : null)?.toString() ?? '';
        final rawUser = (data is Map) ? data['user'] : null;

        if (token.isEmpty || rawUser == null) {
          _showError("Login response missing token/user");
          return;
        }

        final Map<String, dynamic> user = Map<String, dynamic>.from(rawUser as Map);
        await AuthService.saveSession(token, user);

        setState(() { _loading = false; _success = true; });
        await Future.delayed(const Duration(milliseconds: 600));

        final bool isAdmin = AuthService.isAdmin;
        final String name = (user['name'] ?? 'User').toString();
        final String empId = (user['id'] ?? user['employee_id'] ?? '').toString();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isAdmin
                ? AdminPage(adminName: name, jwtToken: token)
                : LunchifyHomePage(
              employeeName: name,
              employeeId: empId,
            ),
          ),
        );
      } else {
        final msg = (data is Map)
            ? (data['message'] ?? data['error'] ?? 'Login failed').toString()
            : 'Login failed (non-JSON response)';
        
        if (msg.toLowerCase().contains('not registered')) {
          _showAccountNotFoundDialog();
        } else {
          _showError(msg);
        }
      }
    } on SocketException catch (e) {
      _showError("SocketException: ${e.message}");
    } on TimeoutException {
      _showError("Timeout: Server took too long to respond");
    } on HttpException catch (e) {
      _showError("HttpException: $e");
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
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
                            context:    context,
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
  final BuildContext context;

  const _FormSection({
    required this.empCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.success,
    required this.onToggle,
    required this.onLogin,
    required this.context,
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
                onSubmitted: (_) => onLogin(),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
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
                              : [const Color(0xFF1A2E6E), const Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A2E6E).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
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
                                    : Icons.lock_rounded,
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
                    child: const Text(
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupPage(),
                      ),
                    );
                  },
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
  final void Function(String)? onSubmitted;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onSubmitted: onSubmitted,
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
