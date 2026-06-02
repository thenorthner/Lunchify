import 'package:flutter/material.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class MenuCategory {
  final String title;
  final String subtitle;
  final String iconEmoji;
  final String todayLabel;
  final String todayItems;
  final String pillEmoji;

  const MenuCategory({
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.todayLabel,
    required this.todayItems,
    required this.pillEmoji,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class TodayMenuPage extends StatelessWidget {
  const TodayMenuPage({super.key});

  static const List<MenuCategory> _categories = [
    MenuCategory(
      title: 'Food Menu',
      subtitle: 'Hearty meals for a wholesome lunch.',
      iconEmoji: '🍱',
      todayLabel: "Today's Special",
      todayItems: 'Dal Tadka, Jeera Rice, Mix Veg, Roti, Salad',
      pillEmoji: '🍚',
    ),
    MenuCategory(
      title: 'Fruit Menu',
      subtitle: 'Fresh and healthy seasonal fruits.',
      iconEmoji: '🍎',
      todayLabel: "Today's Fruits",
      todayItems: 'Apple, Banana, Orange, Watermelon',
      pillEmoji: '🍊',
    ),
    MenuCategory(
      title: 'Morning Snacks',
      subtitle: 'Energizing bites to start your day.',
      iconEmoji: '☕',
      todayLabel: "Today's Snack",
      todayItems: 'Veg Sandwich, Poha, Tea',
      pillEmoji: '🍪',
    ),
    MenuCategory(
      title: 'Evening Snacks',
      subtitle: 'Tasty snacks to recharge your evening.',
      iconEmoji: '🌙',
      todayLabel: "Today's Snack",
      todayItems: 'Samosa, Cake Slice, Green Tea',
      pillEmoji: '🥟',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF9),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  ..._categories.map((cat) => _AnimatedMenuCard(category: cat)),
                  const SizedBox(height: 8),
                  _DisclaimerBanner(),
                ],
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
          // Background image — add your asset at assets/images/food_tray_bg.png
          Positioned.fill(
            child: Image.asset(
              'assets/images/food_tray_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD0DCF0),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.45, 0.75, 1.0],
                  colors: [
                    Color(0xF7E8EEF9),
                    Color(0xD0E8EEF9),
                    Color(0x55E8EEF9),
                    Color(0x08E8EEF9),
                  ],
                ),
              ),
            ),
          ),
          // Back button + title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AnimatedBackButton(),
                const SizedBox(width: 10),
                const Text(
                  "Today's Menu",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A3A6B),
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
class _AnimatedBackButton extends StatefulWidget {
  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
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
                color: Color.lerp(
                  Colors.white.withOpacity(0.92),
                  Colors.white,
                  _ctrl.value,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1A3A6B),
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Menu Card ───────────────────────────────────────────────────────
class _AnimatedMenuCard extends StatefulWidget {
  final MenuCategory category;
  const _AnimatedMenuCard({required this.category});

  @override
  State<_AnimatedMenuCard> createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<_AnimatedMenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _cardLift;
  late final Animation<double> _cardScale;
  late final Animation<double> _overlayOpacity;
  late final Animation<double> _iconRotate;
  late final Animation<double> _iconScale;
  late final Animation<double> _chevronSlide;
  late final Animation<double> _pillScale;
  late final Animation<double> _pillRotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    final spring = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    final ease   = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _cardLift       = Tween<double>(begin: 0,    end: -5   ).animate(spring);
    _cardScale      = Tween<double>(begin: 1.0,  end: 1.013).animate(spring);
    _overlayOpacity = Tween<double>(begin: 0,    end: 1    ).animate(ease);
    _iconRotate     = Tween<double>(begin: 0,    end: -0.17).animate(spring);
    _iconScale      = Tween<double>(begin: 1.0,  end: 1.14 ).animate(spring);
    _chevronSlide   = Tween<double>(begin: 0,    end: 6    ).animate(spring);
    _pillScale      = Tween<double>(begin: 1.0,  end: 1.18 ).animate(spring);
    _pillRotate     = Tween<double>(begin: 0,    end: 0.14 ).animate(spring);
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
        onTapDown:  (_) => _ctrl.forward(),
        onTapUp:    (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: () {
          // TODO: navigate to detail page
        },
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(0.0, _cardLift.value)
                ..scale(_cardScale.value),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.lerp(
                      Colors.transparent,
                      const Color(0xFFA8C4E8),
                      _ctrl.value,
                    )!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF185FA5)
                          .withOpacity(0.06 + 0.07 * _ctrl.value),
                      blurRadius: 8 + 20 * _ctrl.value,
                      offset: Offset(0, 4 + 6 * _ctrl.value),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Shimmer overlay on hover
                      Positioned.fill(
                        child: Opacity(
                          opacity: _overlayOpacity.value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0x22DCE8F7), Colors.transparent],
                                stops: [0.0, 0.6],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header row ──────────────────────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon circle — rotates and scales
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateZ(_iconRotate.value)
                                    ..scale(_iconScale.value),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Color.lerp(
                                        const Color(0xFFE8EEF9),
                                        const Color(0xFFCFDDF5),
                                        _ctrl.value,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.category.iconEmoji,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Title + subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.category.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1A3A6B),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        widget.category.subtitle,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF6B7A99),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Chevron — slides right
                                Transform.translate(
                                  offset: Offset(_chevronSlide.value, 0),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Color.lerp(
                                        const Color(0xFFE8EEF9),
                                        const Color(0xFFBDD2EE),
                                        _ctrl.value,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF4A7AC7),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // ── Preview pill ─────────────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  const Color(0xFFF0F4FB),
                                  const Color(0xFFE2ECF8),
                                  _ctrl.value,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pill icon — scales and spins
                                  Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..scale(_pillScale.value)
                                      ..rotateZ(_pillRotate.value),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDCE6F5),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.category.pillEmoji,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.category.todayLabel,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2D5DB5),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.category.todayItems,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF4A5568),
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Disclaimer Banner ────────────────────────────────────────────────────────
class _DisclaimerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCD6EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF1A3A6B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu is updated daily.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A6B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Items are subject to change based on availability.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7A99)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Entry point ──────────────────────────────────────────────────────────────
// void main() {
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: TodayMenuPage(),
//     ),
//   );
// }