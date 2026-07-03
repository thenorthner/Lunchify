import 'package:flutter/material.dart';
import 'update_full_menu_page.dart';
import 'admin_orders_page.dart';
import 'qr_scanner.dart';
import 'snack_requests_page.dart';
import 'admin_scan_history_page.dart';
import 'admin_pending_requests_page.dart';
import 'login_page.dart';
import 'auth_service.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kNavy    = Color(0xFF1A2E6E);
const _kAccent  = Color(0xFF2563EB);
const _kBg      = Color(0xFFEAF2FF);
const _kCard    = Color(0xFFFFFFFF);
const _kLight   = Color(0xFFDBE9FF);
const _kSubtext = Color(0xFF5A7CC9);

// ─── Admin Menu Item Model ────────────────────────────────────────────────────
class _AdminMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

// ════════════════════════════════════════════════════════════════════════════
//  ADMIN PAGE
// ════════════════════════════════════════════════════════════════════════════
class AdminPage extends StatelessWidget {
  final String adminName;
  final String jwtToken;

  const AdminPage({
    super.key,
    required this.adminName,
    required this.jwtToken,
  });

  @override
  Widget build(BuildContext context) {
    // ── Menu items defined here so context is available for navigation ──────
    final menuItems = [
      _AdminMenuItem(
        icon: Icons.edit_rounded,
        title: "Set Today's Menu",
        subtitle: "Add or update today's food & fruit menu",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateFullMenuPage()));
        },
      ),
      _AdminMenuItem(
        icon: Icons.checklist_rounded,
        title: "Track Lunch Orders",
        subtitle: "Track and mark food & fruit lunch orders",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersPage()));
        },
      ),
      _AdminMenuItem(
        icon: Icons.qr_code_scanner_rounded,
        title: "Scan QR",
        subtitle: "Scan QR to record lunch",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => QRScannerPage(scannerId: adminName)));
        },
      ),
      _AdminMenuItem(
        icon: Icons.receipt_long_rounded,
        title: "Snack Orders",
        subtitle: "View and manage snack orders",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SnackRequestsPage()));
        },
      ),
      _AdminMenuItem(
        icon: Icons.history_rounded,
        title: "Scan History",
        subtitle: "View QR scan history for this month",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScanHistoryPage()));
        },
      ),
    ];

    final role = AuthService.user?['role'];
    if (role == 'scanner') {
      menuItems.removeWhere((item) => 
        item.title != "Scan QR" && 
        item.title != "Scan History" && 
        item.title != "Track Lunch Orders"
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 16,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    // ── Hero Header ───────────────────────────────────────────
                    const _Header(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: _WelcomeCard(adminName: adminName),
                    ),
                    // Menu cards
                        ...menuItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _AdminCard(item: item),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Logout button
                        _LogoutButton(
                          onLogout: () {
                            AuthService.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (route) => false,
                            );
                          },
                        ),
                  ],
                ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.lunch_dining,
                          size: 40,
                          color: _kAccent,
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
                            color: _kAccent,
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
  final String adminName;
  const _WelcomeCard({required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withOpacity(0.08),
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
              color: _kLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: _kAccent, size: 32),
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
                          color: _kNavy,
                          fontFamily: 'FKGrotesk',
                        ),
                      ),
                      TextSpan(
                        text: adminName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _kAccent,
                          fontFamily: 'FKGrotesk',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthService.user?['role'] == 'scanner' 
                      ? 'Welcome to Lunchify Scanner!' 
                      : 'Welcome to Lunchify Admin!',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _kSubtext,
                    fontWeight: FontWeight.w500,
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

// ─── Admin Card ───────────────────────────────────────────────────────────────
class _AdminCard extends StatefulWidget {
  final _AdminMenuItem item;
  const _AdminCard({super.key, required this.item});

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) {
        setState(() => _pressed = false);
        widget.item.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFFF0F6FF) : _kCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withOpacity(_pressed ? 0.12 : 0.07),
                blurRadius: _pressed ? 20 : 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _kLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.item.icon, color: _kAccent, size: 26),
              ),

              const SizedBox(width: 16),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kSubtext,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_rounded,
                color: _kAccent,
                size: 22,
              ),
            ],
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
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) {
        setState(() => _pressed = false);
        widget.onLogout();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
