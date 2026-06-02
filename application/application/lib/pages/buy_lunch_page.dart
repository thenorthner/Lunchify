import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A2E6E);
const _kBlue   = Color(0xFF1E5CBF);
const _kAccent = Color(0xFF2563EB);
const _kBg     = Color(0xFFEAF2FF);
const _kCard   = Color(0xFFFFFFFF);
const _kLight  = Color(0xFFDBE9FF);
const _kSubtext= Color(0xFF5A7CC9);
const _kPill   = Color(0xFFEEF4FF);
const _kBorder = Color(0xFFDCE8F5);

// ─── Buy Lunch Page ───────────────────────────────────────────────────────────
class BuyLunchPage extends StatefulWidget {
  const BuyLunchPage({super.key});

  @override
  State<BuyLunchPage> createState() => _BuyLunchPageState();
}

class _BuyLunchPageState extends State<BuyLunchPage> {
  // Simulated QR expiry time
  final DateTime _expiresAt = DateTime(2026, 5, 18, 19, 24);
  bool _qrVisible = true;

  String get _formattedExpiry {
    final d = _expiresAt;
    final hour = d.hour > 12 ? d.hour - 12 : d.hour == 0 ? 12 : d.hour;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min  = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day}/${d.year} $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── Fruit Lunch row card ──────────────────────────────────
                    _ActionCard(
                      icon: Icons.set_meal_rounded,
                      title: 'Fruit Lunch',
                      subtitle: 'Choose healthy & fresh options',
                      onTap: () {},
                    ),

                    const SizedBox(height: 14),

                    // ── Regenerate QR row card ────────────────────────────────
                    _ActionCard(
                      icon: Icons.sync_rounded,
                      title: 'Regenerate QR',
                      subtitle: 'Generate a new QR code',
                      onTap: () {
                        setState(() => _qrVisible = !_qrVisible);
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Info banner ───────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _kPill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            color: _kAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Show this QR to admin. It is valid for one scan only.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _kNavy,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Expires at: ',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: _kSubtext,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _formattedExpiry,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: _kAccent,
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

                    const SizedBox(height: 20),

                    // ── QR Code box ───────────────────────────────────────────
                    AnimatedOpacity(
                      opacity: _qrVisible ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 300),
                      child: Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _kCard,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _kBlue.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _QrCodePainterWidget(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Action buttons ────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryButton(
                            icon: Icons.check_rounded,
                            label: 'Check Status',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OutlineButton(
                            label: 'Cancel QR',
                            onTap: () {
                              setState(() => _qrVisible = false);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Important Note banner ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                        boxShadow: [
                          BoxShadow(
                            color: _kBlue.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: _kAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Important Note',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _kNavy,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'This QR code can be used for a single scan only and cannot be reused.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _kSubtext,
                                    height: 1.5,
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
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
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
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/food_tray_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFD0DCF0)),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.45, 0.72, 1.0],
                  colors: [
                    Color(0xF5EAF2FF),
                    Color(0xCCEAF2FF),
                    Color(0x55EAF2FF),
                    Color(0x05EAF2FF),
                  ],
                ),
              ),
            ),
          ),
          // Back button + title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BackButton(),
                const SizedBox(width: 10),
                const Text(
                  'Buy Lunch',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
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

// ─── Action Card (Fruit Lunch / Regenerate QR rows) ──────────────────────────
class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kBlue.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: _kLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: _kAccent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _kAccent, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
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
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kNavy, _kAccent],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _kNavy.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

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
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _kAccent, width: 1.8),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── QR Code Painter ─────────────────────────────────────────────────────────
// Draws a realistic-looking QR code pattern using CustomPaint
class _QrCodePainterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _QrPainter(),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final s = size.width / 21; // 21x21 QR grid

    // QR module matrix (simplified realistic-looking pattern)
    const matrix = [
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,0,0,1],
      [1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,0,0,0,1,0,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1],
      [1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0,0,0],
      [1,0,1,1,0,1,1,1,0,0,1,0,1,1,1,0,1,0,1,1,0],
      [0,1,0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,1,0,0,1],
      [1,0,1,0,1,1,1,1,0,1,1,0,1,1,1,0,1,0,1,0,1],
      [0,1,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,1,0,1,0],
      [1,0,1,1,1,0,1,1,0,1,1,1,0,1,1,0,1,0,1,1,1],
      [0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,1,0,0,0,0],
      [1,1,1,1,1,1,1,0,0,1,0,0,1,0,1,0,0,1,0,1,0],
      [1,0,0,0,0,0,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1],
      [1,0,1,1,1,0,1,1,0,1,0,0,1,0,1,0,0,1,0,0,0],
      [1,0,1,1,1,0,1,0,1,0,1,0,0,1,0,1,0,0,1,0,1],
      [1,0,1,1,1,0,1,0,0,1,0,1,1,0,1,0,1,1,0,1,0],
      [1,0,0,0,0,0,1,0,1,0,1,0,0,1,0,0,0,0,1,0,1],
      [1,1,1,1,1,1,1,0,0,1,0,1,1,0,1,1,1,0,0,1,0],
    ];

    for (int row = 0; row < 21; row++) {
      for (int col = 0; col < 21; col++) {
        if (matrix[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(col * s, row * s, s - 0.5, s - 0.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
