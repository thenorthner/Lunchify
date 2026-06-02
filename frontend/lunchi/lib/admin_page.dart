import 'package:flutter/material.dart';
import 'update_full_menu_page.dart';
import 'admin_orders_page.dart';
import 'qr_scanner.dart';
import 'snack_requests_page.dart';
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
        icon: Icons.shopping_cart_outlined,
        title: "View Lunch Orders",
        subtitle: "View all lunch orders placed by employees",
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
        icon: Icons.pending_actions_rounded,
        title: "Pending Approvals",
        subtitle: "Review and approve pending requests",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPendingRequestsPage()));
        },
      ),
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Column(
              children: [
                // ── Hero Header ───────────────────────────────────────────
                _HeroHeader(adminName: adminName),

                // ── Scrollable Content ────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 40 : 16,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String adminName;
  const _HeroHeader({required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color(0xFFD0DCF0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // ── Background image ───────────────────────────────────────────
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

          // ── Left-fade gradient so text stays readable ──────────────────
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

          // ── Text ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 36, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Hi, $adminName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _kNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Text(
                      'Welcome to Lunchify! ',
                      style: TextStyle(
                        fontSize: 15,
                        color: _kSubtext,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text('👋', style: TextStyle(fontSize: 16)),
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
            color: _kAccent,
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