import 'package:flutter/material.dart';

// ─── Colors (matching app palette) ───────────────────────────────────────────
const _kNavy    = Color(0xFF1A2E6E);
const _kBlue    = Color(0xFF1E5CBF);
const _kAccent  = Color(0xFF2563EB);
const _kBg      = Color(0xFFEAF2FF);
const _kCard    = Color(0xFFFFFFFF);
const _kSubtext = Color(0xFF5A7CC9);
const _kLight   = Color(0xFFDBE9FF);
const _kPill    = Color(0xFFEEF4FF);

// ─── Coupon Status Page ───────────────────────────────────────────────────────
class CouponStatusPage extends StatelessWidget {
  const CouponStatusPage({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hello, Kshitij Sharma ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _kNavy,
                            ),
                          ),
                          TextSpan(
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
                        color: _kSubtext,
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
                            count: '2',
                            label: 'Coupons Used',
                            description: 'Total coupons you have used.',
                            pillIcon: Icons.bar_chart_rounded,
                            pillTitle: 'Keep it up!',
                            pillSubtitle: "You're making the most of your benefits.",
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _CouponCard(
                            icon: Icons.confirmation_number_rounded,
                            count: '20',
                            label: 'Coupons Left',
                            description: 'Total coupons remaining for use.',
                            pillIcon: Icons.card_giftcard_rounded,
                            pillTitle: 'Plenty to go!',
                            pillSubtitle: 'Enjoy your meals ahead.',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Bottom row (one card + empty space) ─────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _CouponCard(
                            icon: Icons.calendar_month_rounded,
                            count: '22',
                            label: 'Monthly Limit',
                            description: 'Total coupons available per month.',
                            pillIcon: Icons.verified_user_rounded,
                            pillTitle: 'All good!',
                            pillSubtitle: 'Your monthly limit is set.',
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(child: SizedBox()), // empty cell
                      ],
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
              semanticLabel: 'SJVN scenic background',
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: Semantics(
        button: true,
        label: 'Go back',
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(_slide.value, 0.0)
                ..scale(_scale.value),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
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
                    child: const Icon(
                      Icons.arrow_back,
                      color: _kNavy,
                      size: 18,
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

// ─── Coupon Card ──────────────────────────────────────────────────────────────
class _CouponCard extends StatefulWidget {
  final IconData icon;
  final String count;
  final String label;
  final String description;
  final IconData pillIcon;
  final String pillTitle;
  final String pillSubtitle;

  const _CouponCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.description,
    required this.pillIcon,
    required this.pillTitle,
    required this.pillSubtitle,
  });

  @override
  State<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends State<_CouponCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _kBlue.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon circle
                ExcludeSemantics(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: _kLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: _kAccent, size: 30),
                  ),
                ),

                const SizedBox(height: 14),

                // Big count number
                Text(
                  widget.count,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: _kAccent,
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
                    color: _kNavy,
                  ),
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kSubtext,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // Bottom pill
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kPill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Icon(widget.pillIcon, color: _kAccent, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pillTitle,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kAccent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.pillSubtitle,
                              style: const TextStyle(
                                fontSize: 11,
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
    );
  }
}
