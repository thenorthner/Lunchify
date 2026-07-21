import 'package:flutter/material.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
const kPrimaryBlue = Color(0xFF1A3A8F);
const kAccentBlue  = Color(0xFF2563EB);
const kLightBlue   = Color(0xFFDBE9FF);
const kBgColor     = Color(0xFFEAF2FF);
const kCardWhite   = Color(0xFFFFFFFF);
const kRedAccent   = Color(0xFFE53935);
const kSubtext     = Color(0xFF5A7CC9);

// ─── Home Screen ─────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const _WelcomeCard(),
                  const SizedBox(height: 20),
                  isWide
                      ? const _GridMenuWide()
                      : const _GridMenuNarrow(),
                  const SizedBox(height: 24),
                  const _LogoutButton(),
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
                semanticLabel: 'SJVN office background',
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFD0DCF0),
                ),
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
                        semanticLabel: 'SJVN logo',
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
                        semanticLabel: 'Lunchify wordmark',
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
class _WelcomeCard extends StatefulWidget {
  const _WelcomeCard();

  @override
  State<_WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<_WelcomeCard> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    final hourStr = now.hour > 12 ? (now.hour - 12).toString() : (now.hour == 0 ? '12' : now.hour.toString());
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hourStr:$minuteStr $ampm';

    // Determine greeting based on hour
    String greeting = 'Good morning,';
    if (now.hour >= 12 && now.hour < 17) {
      greeting = 'Good afternoon,';
    } else if (now.hour >= 17) {
      greeting = 'Good evening,';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FAFC),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          // Food Illustration
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.95,
              child: Image.asset(
                'assets/images/food_tray_bg.png',
                width: 170,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // App Icon / Top right button
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_menu, color: kAccentBlue, size: 24),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Let\'s Feast, ',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: 'Kshitij',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: kAccentBlue,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.flare, color: Colors.amber, size: 26),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Great food boosts productivity and happiness! 😀',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 1,
                      height: 12,
                      color: const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
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

// ─── Menu Items Data ──────────────────────────────────────────────────────────
class _HomeMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? badge;
  final String? route; // ✅ added route support

  const _HomeMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.route,
  });
}

final _menuItems = [
  const _HomeMenuItem(
    icon: Icons.restaurant_menu_rounded,
    title: "Today's Menu",
    subtitle: "See what's cooking today",
    route: '/menu', // ✅ wired to menu page
  ),
  _HomeMenuItem(
    icon: Icons.confirmation_number_rounded,
    title: "Coupons Used",
    subtitle: "2 coupons used this month",
    route: '/coupons', // ✅ wired to coupon status page
    badge: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: kLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          '2',
          style: TextStyle(
            color: kPrimaryBlue,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    ),
  ),
  const _HomeMenuItem(
    icon: Icons.qr_code_2_rounded,
    title: "Buy Lunch & Show QR",
    subtitle: "Buy your lunch & show QR at canteen",
    route: '/buy-lunch', // ✅ wired!
  ),
  const _HomeMenuItem(
    icon: Icons.room_service_rounded,
    title: "Order Snacks",
    subtitle: "Order your favorite snacks",
  ),
  const _HomeMenuItem(
    icon: Icons.assignment_rounded,
    title: "Order Status",
    subtitle: "Track your orders",
  ),
  const _HomeMenuItem(
    icon: Icons.history_rounded,
    title: "Order History",
    subtitle: "View your past orders",
  ),
];

// ─── Grid Menu – Narrow (2-column) ───────────────────────────────────────────
class _GridMenuNarrow extends StatelessWidget {
  const _GridMenuNarrow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _menuItems.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(child: _MenuCard(item: _menuItems[i])),
                const SizedBox(width: 14),
                Expanded(
                  child: i + 1 < _menuItems.length
                      ? _MenuCard(item: _menuItems[i + 1])
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
  const _GridMenuWide();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _menuItems.length; i += 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                for (int j = i; j < i + 3 && j < _menuItems.length; j++) ...[
                  Expanded(child: _MenuCard(item: _menuItems[j])),
                  if (j < i + 2 && j + 1 < _menuItems.length)
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
    return Semantics(
      button: true,
      label: '${widget.item.title}. ${widget.item.subtitle}',
      child: GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        // ✅ Navigate if a route is defined
        if (widget.item.route != null) {
          Navigator.pushNamed(context, widget.item.route!);
        }
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
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
                    child: Icon(widget.item.icon, color: kPrimaryBlue, size: 22),
                  ),
                  const Spacer(),
                  if (widget.item.badge != null) widget.item.badge!,
                  if (widget.item.badge == null)
                    const Icon(Icons.chevron_right_rounded, color: kAccentBlue, size: 22),
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
                  child: Icon(Icons.chevron_right_rounded, color: kAccentBlue, size: 20),
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
  const _LogoutButton();

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
      onTap: () {
        // ✅ Logout: go back to login and clear stack
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: kPrimaryBlue,
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
            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
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
                      ),
                    ),
                    TextSpan(
                      text: 'SJVN',
                      style: TextStyle(
                        fontSize: 13,
                        color: kAccentBlue,
                        fontWeight: FontWeight.w800,
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
