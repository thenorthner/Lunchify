import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'config.dart';
import 'auth_service.dart';
import 'app_theme.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class MenuCategory {
  final String keyName;
  final String title;
  final String subtitle;
  final String iconEmoji;
  final String todayLabel;
  final String pillEmoji;
  final bool fromSnacks;

  const MenuCategory({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.todayLabel,
    required this.pillEmoji,
    this.fromSnacks = false,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class TodayMenuPage extends StatefulWidget {
  const TodayMenuPage({super.key});

  @override
  State<TodayMenuPage> createState() => _TodayMenuPageState();
}

class _TodayMenuPageState extends State<TodayMenuPage> {
  static const List<MenuCategory> _categories = [
    MenuCategory(
      keyName: 'food',
      title: 'Food Menu',
      subtitle: 'Hearty meals for a wholesome lunch.',
      iconEmoji: '🍱',
      todayLabel: "Today's Special",
      pillEmoji: '🍚',
    ),
    MenuCategory(
      keyName: 'fruit',
      title: 'Fruit Menu',
      subtitle: 'Fresh and healthy seasonal fruits.',
      iconEmoji: '🍎',
      todayLabel: "Today's Fruits",
      pillEmoji: '🍊',
    ),
    MenuCategory(
      keyName: 'morning',
      title: 'Morning Snacks',
      subtitle: 'Energizing bites to start your day.',
      iconEmoji: '☕',
      todayLabel: "Today's Snack",
      pillEmoji: '🍪',
      fromSnacks: true,
    ),
    MenuCategory(
      keyName: 'evening',
      title: 'Evening Snacks',
      subtitle: 'Tasty snacks to recharge your evening.',
      iconEmoji: '🌙',
      todayLabel: "Today's Snack",
      pillEmoji: '🥟',
      fromSnacks: true,
    ),
  ];

  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  dynamic _safeJsonDecode(http.Response res) {
    final raw = res.body.trimLeft();
    if (raw.startsWith('<')) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }

  List<String> _parse(dynamic body) {
    if (body == null) return [];
    if (body is List) {
      return body.map((e) {
        if (e is Map) return e['name']?.toString() ?? e.toString();
        return e.toString();
      }).toList();
    }
    if (body is Map && body['items'] is List) {
      return (body['items'] as List).map((e) {
        if (e is Map) return e['name']?.toString() ?? e.toString();
        return e.toString();
      }).toList().cast<String>();
    }
    if (body is Map && body['fruits'] is List) {
      return (body['fruits'] as List).map((e) {
        if (e is Map) return e['name']?.toString() ?? e.toString();
        return e.toString();
      }).toList().cast<String>();
    }
    return [];
  }

  Map<String, List<String>> editable = {
    "food": [],
    "fruit": [],
    "morning": [],
    "evening": [],
  };

  Future<Map<String, List<String>>> _fetchMenu() async {
    final date = _today();
    final headers = {
      'Authorization': 'Bearer ${AuthService.token}',
    };

    final res = await Future.wait([
      http.get(Uri.parse(AppConfig.foodMenuByDate(date)), headers: headers),
      http.get(Uri.parse(AppConfig.fruitMenuByDate(date)), headers: headers),
      http.get(Uri.parse(AppConfig.snacksMenu(date, "morning")), headers: headers),
      http.get(Uri.parse(AppConfig.snacksMenu(date, "evening")), headers: headers),
    ]);

    editable["food"] = res[0].statusCode == 200 ? _parse(_safeJsonDecode(res[0])) : [];
    editable["fruit"] = res[1].statusCode == 200 ? _parse(_safeJsonDecode(res[1])) : [];
    editable["morning"] = res[2].statusCode == 200 ? _parse(_safeJsonDecode(res[2])) : [];
    editable["evening"] = res[3].statusCode == 200 ? _parse(_safeJsonDecode(res[3])) : [];

    return editable;
  }

  Future<void> _saveFood() async {
    await http.post(
      Uri.parse(AppConfig.saveFoodMenu),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode({
        "menu_date": _today(),
        "items": editable["food"],
      }),
    );
    _toast("🍱 Food menu saved");
  }

  Future<void> _saveFruit() async {
    await http.post(
      Uri.parse(AppConfig.saveFruitMenu),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode({
        "menu_date": _today(),
        "fruits": editable["fruit"],
      }),
    );
    _toast("🍓 Fruit menu saved");
  }

  Future<void> _saveSnacks(String session) async {
    await http.post(
      Uri.parse(AppConfig.saveSnacksMenu),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode({
        "menu_date": _today(),
        "session": session,
        "items": editable[session],
      }),
    );
    _toast("✅ $session snacks saved");
  }

  Future<List<String>> _fetchActiveSnacks() async {
    final res = await http.get(
      Uri.parse(AppConfig.activeSnacksItems),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    return List<String>.from(data.map((e) => e['name']));
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editList(String key, String title, bool fromSnacks) async {
    final controller = TextEditingController();
    final selected = Set<String>.from(editable[key]!);

    final source = fromSnacks ? await _fetchActiveSnacks() : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.all(16).copyWith(
             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit $title", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kNavy)),
              const SizedBox(height: 10),

              if (!fromSnacks)
                 ...selected.map((item) => ListTile(
                   title: Text(item),
                   trailing: IconButton(
                     icon: const Icon(Icons.remove_circle, color: kRedAccent),
                     onPressed: () => setModal(() => selected.remove(item)),
                   ),
                 )),

              if (fromSnacks)
                ...source.map((item) => CheckboxListTile(
                  title: Text(item),
                  value: selected.contains(item),
                  onChanged: (v) {
                    setModal(() {
                      v! ? selected.add(item) : selected.remove(item);
                    });
                  },
                ))
              else
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "Add item"),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      setModal(() {
                        selected.add(v.trim());
                        controller.clear();
                      });
                    }
                  },
                ),

              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, foregroundColor: Colors.white),
                onPressed: () async {
                  setState(() => editable[key] = selected.toList());
                  Navigator.pop(context);
                  
                  if (key == 'food') await _saveFood();
                  if (key == 'fruit') await _saveFruit();
                  if (key == 'morning') await _saveSnacks('morning');
                  if (key == 'evening') await _saveSnacks('evening');
                },
                child: const Text("Done & Save"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = AuthService.isAdmin;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF9),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: FutureBuilder<Map<String, List<String>>>(
                future: _fetchMenu(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: kPrimaryBlue));
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (isAdmin)
                        const Padding(
                           padding: EdgeInsets.only(bottom: 12),
                           child: Text("Tap on any category to edit the menu.", textAlign: TextAlign.center, style: TextStyle(color: kGray)),
                        ),
                      ..._categories.map((cat) {
                         final itemsList = editable[cat.keyName] ?? [];
                         final todayItemsStr = itemsList.isEmpty ? "No items added yet" : itemsList.join(', ');
                         
                         return _AnimatedMenuCard(
                           category: cat,
                           todayItemsStr: todayItemsStr,
                           onTap: isAdmin ? () => _editList(cat.keyName, cat.title, cat.fromSnacks) : null,
                         );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                },
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
  final String todayItemsStr;
  final VoidCallback? onTap;

  const _AnimatedMenuCard({required this.category, required this.todayItemsStr, this.onTap});

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
        onTap: widget.onTap,
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
                                // Chevron / Edit icon — slides right
                                if (widget.onTap != null)
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
                                        Icons.edit,
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
                                children: [
                                  Text(widget.category.pillEmoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.category.todayLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kNavy)),
                                        Text(widget.todayItemsStr, style: const TextStyle(fontSize: 12, color: kSubtext)),
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
