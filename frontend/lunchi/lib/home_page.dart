import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';

import 'config.dart';
import 'login_page.dart';
import 'todays_menu.dart';
import 'qr_buy_lunch_page.dart';
import 'snack_order_employee.dart';
import 'coupon_count.dart';
import 'snack_order_status_page.dart';
import 'snack_order_history_page.dart';
import 'auth_service.dart';
import 'feedback_page.dart';
import 'lunch_rating_selection_screen.dart';
import 'app_theme.dart'; // <-- added import
import 'snack_hub_page.dart';
import 'support_ratings_hub.dart';
import 'share_coupons_page.dart';

class LunchifyHomePage extends StatefulWidget {
  final String employeeName;
  final String employeeId;

  const LunchifyHomePage({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  State<LunchifyHomePage> createState() => _LunchifyHomePageState();
}

class _LunchifyHomePageState extends State<LunchifyHomePage> {
  int _couponCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCouponCount();
  }

  Future<void> _fetchCouponCount() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/coupons/${widget.employeeId}'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _couponCount = data['couponsUsed'] ?? 0;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load coupons');
      }
    } catch (e) {
      debugPrint("❌ Error fetching coupons: $e");
      setState(() => _isLoading = false);
    }
  }

  void _logout(BuildContext context) {
    AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  List<_HomeMenuItem> get _menuItems => [
    _HomeMenuItem(
      icon: Icons.restaurant_menu_rounded,
      title: "Today's Menu",
      subtitle: "See what's cooking today",
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TodayMenuPage()),
      ),
    ),
    _HomeMenuItem(
      icon: Icons.confirmation_number_rounded,
      title: "Coupons Status",
      subtitle: "$_couponCount coupons used",
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CouponStatusPage(employeeId: widget.employeeId),
          ),
        );
        _fetchCouponCount();
      },
      badge: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: kLightBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$_couponCount',
            style: const TextStyle(
              color: kPrimaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
    _HomeMenuItem(
      icon: Icons.qr_code_2_rounded,
      title: "Redeem Coupon & Show QR",
      subtitle: "Redeem your coupon & show QR at canteen",
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BuyLunchQrPage(
              employeeId: widget.employeeId,
              employeeName: widget.employeeName,
            ),
          ),
        );
        _fetchCouponCount();
      },
    ),
    _HomeMenuItem(
      icon: Icons.fastfood_rounded,
      title: "Canteen Hub",
      subtitle: "Order food, snacks & track history",
      isDisabled: !(AuthService.user?['is_gm_or_above'] == true),
      onTap: () {
        if (!(AuthService.user?['is_gm_or_above'] == true)) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_rounded, color: Colors.redAccent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "This ain't for everyone!",
                      style: TextStyle(
                        fontWeight: FontWeight.w800, 
                        fontSize: 18, 
                        color: Color(0xFF1A3A8F), // kPrimaryBlue
                      ),
                    ),
                  ),
                ],
              ),
              content: const Text(
                "This lunch/snacks order feature is only for the big boss gang (GM & above) 🗿. Meanwhile, the rest of us gotta hit the canteen.",
                style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A8F), // kPrimaryBlue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it, Chief ✌️',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SnackHubPage(employeeId: widget.employeeId),
          ),
        );
      },
    ),
    _HomeMenuItem(
      icon: Icons.card_giftcard_rounded,
      title: "Share Coupons",
      subtitle: "Send coupons to others",
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShareCouponsPage()),
        );
        _fetchCouponCount();
      },
    ),
    _HomeMenuItem(
      icon: Icons.headset_mic_rounded,
      title: "Rating & Feedback",
      subtitle: "Rate menu or report bugs",
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SupportRatingsHub()),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBgColor,
        body: Center(child: CircularProgressIndicator(color: kPrimaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 16,
                vertical: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: 20),
                  _WelcomeCard(employeeName: widget.employeeName),
                  const SizedBox(height: 20),
                  isWide
                      ? _GridMenuWide(items: _menuItems)
                      : _GridMenuNarrow(items: _menuItems),
                  const SizedBox(height: 24),
                  _LogoutButton(onLogout: () => _logout(context)),
                  const SizedBox(height: 16),
                  const _FooterBadge(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/sjvn_bg.png',
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFFD0DCF0)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.78),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 60,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.lunch_dining,
                          size: 40,
                          color: kPrimaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/w_logo.png',
                        width: 120,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'Lunchify',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: kPrimaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Welcome Card ─────────────────────────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  final String employeeName;
  const _WelcomeCard({required this.employeeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: kCardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: kLightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: kPrimaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Hi, ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryBlue,
                          fontFamily: 'EBGaramond',
                        ),
                      ),
                      TextSpan(
                        text: employeeName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kAccentBlue,
                          fontFamily: 'EBGaramond',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome to Lunchify!',
                  style: TextStyle(
                    fontSize: 14,
                    color: kSubtext,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 56,
            decoration: BoxDecoration(
              color: kLightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dinner_dining,
              color: kAccentBlue,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Items Data ──────────────────────────────────────────────────────────
class _HomeMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? badge;
  final VoidCallback onTap;
  final bool isDisabled;

  const _HomeMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
    this.isDisabled = false,
  });
}

// ─── Grid Menu – Narrow (2-column) ───────────────────────────────────────────
class _GridMenuNarrow extends StatelessWidget {
  final List<_HomeMenuItem> items;
  const _GridMenuNarrow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(child: _MenuCard(item: items[i])),
                const SizedBox(width: 14),
                Expanded(
                  child: i + 1 < items.length
                      ? _MenuCard(item: items[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Grid Menu – Wide (3-column) ─────────────────────────────────────────────
class _GridMenuWide extends StatelessWidget {
  final List<_HomeMenuItem> items;
  const _GridMenuWide({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                for (int j = i; j < i + 3 && j < items.length; j++) ...[
                  Expanded(child: _MenuCard(item: items[j])),
                  if (j < i + 2 && j + 1 < items.length)
                    const SizedBox(width: 16),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Menu Card ────────────────────────────────────────────────────────────────
class _MenuCard extends StatefulWidget {
  final _HomeMenuItem item;
  const _MenuCard({super.key, required this.item});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.item.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: widget.item.isDisabled ? 0.45 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryBlue.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kLightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: kPrimaryBlue,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    if (widget.item.badge != null) widget.item.badge!,
                    if (widget.item.badge == null)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: kAccentBlue,
                        size: 22,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryBlue,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kSubtext,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                if (widget.item.badge != null) ...[
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: kAccentBlue,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onLogout,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryBlue.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer Badge ─────────────────────────────────────────────────────────────
class _FooterBadge extends StatelessWidget {
  const _FooterBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: kCardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: kPrimaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Secure. Simple. Smart.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryBlue,
                ),
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Lunchify by ',
                      style: TextStyle(
                        fontSize: 13,
                        color: kSubtext,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'EBGaramond',
                      ),
                    ),
                    TextSpan(
                      text: 'SJVN Limited',
                      style: TextStyle(
                        fontSize: 13,
                        color: kAccentBlue,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'EBGaramond',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
