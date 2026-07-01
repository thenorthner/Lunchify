import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'config.dart';
import 'auth_service.dart';
import 'app_theme.dart';
import 'coupon_history_page.dart';

class CouponStatusPage extends StatefulWidget {
  final String employeeId;

  const CouponStatusPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<CouponStatusPage> createState() => _CouponStatusPageState();
}

class _CouponStatusPageState extends State<CouponStatusPage> {
  bool isLoading = true;
  String? error;

  String name = '';
  int couponsUsed = 0;
  int couponsLeft = 0;
  int monthlyLimit = 0;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/coupons/${widget.employeeId}'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          name = data['name'] ?? '';
          couponsUsed = data['couponsUsed'] ?? 0;
          couponsLeft = data['couponsLeft'] ?? 0;
          monthlyLimit = data['monthlyLimit'] ?? 0;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load coupons');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
                  : error != null
                      ? Center(
                          child: Text(
                            error!,
                            style: const TextStyle(color: kRed),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchCoupons,
                          color: kPrimaryBlue,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Greeting
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Hello, $name ',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: kNavy,
                                          fontFamily: 'EBGaramond',
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '👋',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Here's an overview of your lunch coupons.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kSubtext,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ── Top two cards (row) ──────────────────────────────────
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CouponCard(
                                        icon: Icons.remove_circle_outline_rounded,
                                        count: couponsUsed.toString(),
                                        label: 'Coupons Used',
                                        description: 'Click to view coupon usage history.',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CouponHistoryPage(employeeId: widget.employeeId),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _CouponCard(
                                        icon: Icons.confirmation_number_rounded,
                                        count: couponsLeft.toString(),
                                        label: 'Coupons Left',
                                        description: 'Total coupons remaining for use.',
                                      ),
                                    ),
                                  ],
                                ),


                              ],
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

// ─── Top Bar with background image ───────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // ── Background image (sjvn_scene.png) ─────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/sjvn_scene.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD0DCF0),
              ),
            ),
          ),
          // ── Gradient overlay (left-fade so text is readable) ───────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.5, 0.75, 1.0],
                  colors: [
                    Color(0xF5EAF2FF),
                    Color(0xCCEAF2FF),
                    Color(0x66EAF2FF),
                    Color(0x0AEAF2FF),
                  ],
                ),
              ),
            ),
          ),
          // ── Back button + title ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BackButton(),
                const SizedBox(width: 10),
                const Text(
                  'Coupon Status',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: kNavy,
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

// ─── Animated Back Button ─────────────────────────────────────────────────────
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
    _slide = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
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
      onExit: (_) => _ctrl.reverse(),
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
                    color: kNavy.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: kNavy,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Coupon Card ──────────────────────────────────────────────────────────────
class _CouponCard extends StatefulWidget {
  final IconData icon;
  final String count;
  final String label;
  final String description;
  final VoidCallback? onTap;

  const _CouponCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.description,
    this.onTap,
  });

  @override
  State<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends State<_CouponCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kBlue.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: kLightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: kAccentBlue, size: 30),
              ),

              const SizedBox(height: 14),

              // Big count number
              Text(
                widget.count,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: kAccentBlue,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 6),

              // Label
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kNavy,
                ),
              ),

              const SizedBox(height: 6),

              // Description
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: kSubtext,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
