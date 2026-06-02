import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'otp_verification_page.dart';
import 'login_page.dart';
import 'config.dart';

// --- Colors -------------------------------------------------------------------
const _kNavy    = Color(0xFF1A2E6E);
const _kAccent  = Color(0xFF2563EB);
const _kBg      = Color(0xFFEAF2FF);
const _kCard    = Color(0xFFFFFFFF);
const _kLight   = Color(0xFFDBE9FF);
const _kSubtext = Color(0xFF8A96A8);
const _kBorder  = Color(0xFFDCE8F5);
const _kFill    = Color(0xFFF0F5FB);

// ----------------------------------------------------------------------------
//  SIGNUP PAGE
// ----------------------------------------------------------------------------
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _empIdCtrl   = TextEditingController();
  final _nameCtrl    = TextEditingController();
  final _deptCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass  = true;
  bool _obscureConfirmPass = true;
  bool _loading      = false;
  bool isEmployeeValid = false;

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
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _show(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFE02020) : _kNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    final t = raw.trimLeft();
    if (t.startsWith('<!doctype') || t.startsWith('<html') || t.startsWith('<')) return null;
    if (!(t.startsWith('{'))) return null;
    try {
      final d = jsonDecode(raw);
      return d is Map<String, dynamic> ? d : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _autoFillEmployee(String empId) async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/check-id/$empId'),
        headers: const {'Accept': 'application/json'},
      );

      final decoded = _tryDecodeMap(res.body);
      if (decoded == null) {
        _clearEmployee();
        return;
      }

      String? name;
      String? department;
      String? phone;

      if (decoded['data'] != null && decoded['data'] is Map) {
        name = decoded['data']['name']?.toString();
        department = decoded['data']['department']?.toString();
        phone = decoded['data']['phone']?.toString();
      } else {
        name = decoded['name']?.toString();
        department = decoded['department']?.toString();
        phone = decoded['phone']?.toString();
      }

      if (name != null && name.isNotEmpty) {
        setState(() {
          _nameCtrl.text = name!;
          _deptCtrl.text = department ?? '';
          if (phone != null && phone.isNotEmpty) {
            _phoneCtrl.text = phone;
          }
          isEmployeeValid = true;
        });
      } else {
        _clearEmployee();
      }
    } catch (_) {
      _clearEmployee();
    }
  }

  void _clearEmployee() {
    setState(() {
      isEmployeeValid = false;
      _nameCtrl.clear();
      _deptCtrl.clear();
      _phoneCtrl.clear();
    });
  }

  Future<void> _handleSignup() async {
    final empId = _empIdCtrl.text.trim().toUpperCase();
    final phone = _phoneCtrl.text.trim();
    final password = _passCtrl.text.trim();
    final confirmPassword = _confirmPassCtrl.text.trim();

    if (!isEmployeeValid) {
      _show("Invalid Employee ID");
      return;
    }

    if (phone.length != 10) {
      _show("Enter valid 10-digit phone number");
      return;
    }

    if (password.length < 4) {
      _show("Password must be at least 4 characters long");
      return;
    }

    if (password != confirmPassword) {
      _show("Create Password and Confirm Password do not match");
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/login-request'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "employeeId": empId,
          "phone": phone,
        }),
      );

      if (res.statusCode == 200) {
        if (mounted) {
          _show('OTP sent! Verify your phone to continue.', isError: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationPage(empId: empId, phone: phone, password: password),
            ),
          );
        }
      } else {
        final body = jsonDecode(res.body);
        _show(body['message'] ?? "OTP request failed (HTTP ${res.statusCode})");
      }
    } catch (_) {
      _show("Cannot reach server");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // -- Top Bar ---------------------------------------------------
            _TopBar(),

            // -- Scrollable Form -------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
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
                            color: _kNavy.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                      child: Column(
                        children: [

                          // -- Avatar icon -------------------------------
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: _kLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: _kAccent,
                              size: 38,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // -- Title -------------------------------------
                          const Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _kNavy,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Fill in your details to get started',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: _kSubtext,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // -- Fields ------------------------------------
                          _InputField(
                            controller: _empIdCtrl,
                            hint: 'Employee ID',
                            icon: Icons.badge_outlined,
                            inputType: TextInputType.text,
                            onChanged: (v) {
                              if (v.length == 5) {
                                _autoFillEmployee(v.toUpperCase());
                              } else if (v.length < 5) {
                                _clearEmployee();
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          _InputField(
                            controller: _nameCtrl,
                            hint: 'Name',
                            icon: Icons.person_outline_rounded,
                            inputType: TextInputType.name,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),

                          _InputField(
                            controller: _deptCtrl,
                            hint: 'Department',
                            icon: Icons.business_outlined,
                            inputType: TextInputType.text,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),

                          _InputField(
                            controller: _phoneCtrl,
                            hint: 'Phone Number',
                            icon: Icons.phone_outlined,
                            inputType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Password field with toggle
                          _InputField(
                            controller: _passCtrl,
                            hint: 'Create Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePass,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _kSubtext,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password field with toggle
                          _InputField(
                            controller: _confirmPassCtrl,
                            hint: 'Confirm Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscureConfirmPass,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _kSubtext,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // -- Verify Phone & Continue button ------------
                          _PrimaryButton(
                            loading: _loading,
                            label: 'Verify Phone & Continue',
                            icon: Icons.verified_user_rounded,
                            onTap: _handleSignup,
                          ),

                          const SizedBox(height: 18),

                          // -- OR divider --------------------------------
                          Row(
                            children: const [
                              Expanded(
                                child: Divider(color: Color(0xFFE0EAF5)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kSubtext,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Color(0xFFE0EAF5)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // -- Already registered? Login button ----------
                          _LoginButton(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // -- Safety note -------------------------------
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F5FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _kBorder),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.shield_outlined,
                                  color: _kAccent,
                                  size: 22,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your information is safe with us.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _kNavy,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'We do not share your details with anyone.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _kSubtext,
                                          height: 1.4,
                                        ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Top Bar ------------------------------------------------------------------
class _TopBar extends StatelessWidget {
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
                    Color(0xFFEAF2FF),
                    Color(0xD0EAF2FF),
                    Color(0x88EAF2FF),
                    Color(0x10EAF2FF),
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
                _BackButton(),
                const SizedBox(width: 10),
                const Text(
                  'SJVN Employee Signup',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
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

// --- Animated Back Button -----------------------------------------------------
class _BackButton extends StatefulWidget {
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<double>(begin: 0, end: -4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kNavy.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: _kNavy, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Input Field --------------------------------------------------------------
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final bool readOnly;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.inputType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      readOnly: readOnly,
      style: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF1A2340),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFB0BFCC),
          fontSize: 14.5,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9BB0CC), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: readOnly ? const Color(0xFFF7FAFD) : _kFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
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

// --- Primary Button -----------------------------------------------------------
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
                color: const Color(0xFF1A2E6E).withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
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
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// --- Login Outline Button -----------------------------------------------------
class _LoginButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LoginButton({required this.onTap});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder, width: 1.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.login_rounded, color: _kAccent, size: 20),
              SizedBox(width: 10),
              Text(
                'Already registered? Login',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _kAccent,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: _kAccent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
