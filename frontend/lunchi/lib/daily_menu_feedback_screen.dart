import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'auth_service.dart'; // To get employeeId
import 'config.dart';  // For backend URL
import 'widgets/top_bar.dart';

class MenuItem {
  final String name;
  int rating;
  String remarks;

  MenuItem({required this.name, this.rating = 0, this.remarks = ''});
}

class FoodIcon extends StatelessWidget {
  final String foodName;
  final double size;

  const FoodIcon({super.key, required this.foodName, this.size = 26});

  static const Map<String, String> _registry = {
    'paneer': '🧀', 'kadhi pakoda': '🍲', 'salad': '🥗', 'dahi': '🥛', 'dal': '🥣',
    'rice': '🍚', 'roti': '🫓', 'sabzi': '🥦', 'chicken': '🍗', 'fish': '🐟',
    'egg': '🥚', 'mutton': '🥩', 'prawn': '🦐', 'soup': '🍜', 'tomato soup': '🍅',
    'sweet corn soup': '🌽', 'dessert': '🍰', 'ice cream': '🍨', 'gulab jamun': '🍮',
    'rasgulla': '⚪', 'jalebi': '🧡', 'kheer': '🥣', 'cake': '🎂', 'fruits': '🍎',
    'apple': '🍎', 'banana': '🍌', 'orange': '🍊', 'mango': '🥭', 'grapes': '🍇',
    'watermelon': '🍉', 'pineapple': '🍍', 'juice': '🧃', 'tea': '🍵', 'coffee': '☕',
    'milk': '🥛', 'lassi': '🥤', 'shake': '🥤', 'soft drink': '🥤', 'water': '💧',
    'rajma': '🫘', 'chole': '🫘', 'bhature': '🫓', 'paratha': '🫓', 'naan': '🫓',
    'poha': '🍚', 'upma': '🍲', 'idli': '⚪', 'dosa': '🥞', 'sambar': '🍲',
    'uttapam': '🥞', 'khichdi': '🍚', 'biryani': '🍛', 'pulao': '🍚', 'burger': '🍔',
    'pizza': '🍕', 'sandwich': '🥪', 'hot dog': '🌭', 'fries': '🍟', 'pasta': '🍝',
    'noodles': '🍜', 'momos': '🥟', 'spring roll': '🥠', 'breakfast': '🍳',
    'omelette': '🍳', 'toast': '🍞', 'cornflakes': '🥣', 'snacks': '🍿', 'samosa': '🥟',
    'kachori': '🥟', 'pakoda': '🍤', 'chips': '🥔', 'popcorn': '🍿', 'sweet': '🍬',
    'chocolate': '🍫', 'barfi': '⬜', 'laddu': '🟠', 'bread': '🍞', 'bun': '🥯',
    'cookie': '🍪', 'donut': '🍩', 'muffin': '🧁', 'potato': '🥔', 'tomato': '🍅',
    'onion': '🧅', 'carrot': '🥕', 'peas': '🟢', 'capsicum': '🫑', 'cauliflower': '🥦',
    'veg': '🥬', 'non veg': '🍖', 'lunch': '🍱', 'dinner': '🍽️', 'meal': '🍛', 'combo': '🍱',
  };

  static String? emojiFor(String name) => _registry[name.toLowerCase().trim()];

  @override
  Widget build(BuildContext context) {
    final emoji = emojiFor(foodName);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: emoji != null
            ? Text(emoji,
                style: TextStyle(fontSize: size * 0.82),
                textAlign: TextAlign.center)
            : Icon(Icons.restaurant_rounded,
                size: size * 0.82, color: const Color(0xFF2B56D6)),
      ),
    );
  }
}

class FoodIconBadge extends StatelessWidget {
  final String foodName;
  const FoodIconBadge({super.key, required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: FoodIcon(foodName: foodName, size: 26),
    );
  }
}

class FoodChipIcon extends StatelessWidget {
  final String foodName;
  const FoodChipIcon({super.key, required this.foodName});

  @override
  Widget build(BuildContext context) => FoodIcon(foodName: foodName, size: 16);
}

abstract class _C {
  static const primary = Color(0xFF1A3A8F);
  static const accent = Color(0xFF2B56D6);
  static const bg = Color(0xFFF0F4FF);
  static const starEmpty = Color(0xFFCDD5E0);
  static const starFill = Color(0xFFFFB800);
  static const sub = Color(0xFF5B6F9A);
}

class DailyMenuFeedbackScreen extends StatefulWidget {
  final String lunchType;
  const DailyMenuFeedbackScreen({super.key, required this.lunchType});
  @override
  State<DailyMenuFeedbackScreen> createState() => _DailyMenuFeedbackScreenState();
}

class _DailyMenuFeedbackScreenState extends State<DailyMenuFeedbackScreen> {
  List<MenuItem> _items = [];
  final List<TextEditingController> _controllers = [];
  bool _isLoading = true;
  String _menuDate = 'Today';

  @override
  void initState() {
    super.initState();
    _fetchTodayMenu();
  }

  Future<void> _fetchTodayMenu() async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final token = AuthService.token ?? '';
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/menu/${widget.lunchType}?date=$todayStr'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // API returns { items: [...] } — a Map, not a List
        List<dynamic> itemsList = [];
        if (data is Map && data['items'] != null) {
          itemsList = data['items'] as List<dynamic>;
        }

        setState(() {
          _items = itemsList
              .map((item) => MenuItem(name: item.toString()))
              .toList();
          for (var _ in _items) _controllers.add(TextEditingController());
          _menuDate = todayStr;
          _isLoading = false;
        });
      } else {
        print('Menu fetch failed: ${response.statusCode} ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching menu: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_items.isEmpty) return;

    final feedbackItems = _items.asMap().entries.map((e) {
      return {
        'name': e.value.name,
        'rating': e.value.rating,
        'remarks': _controllers[e.key].text.trim()
      };
    }).toList();

    final hasAnyInput = feedbackItems.any((item) => (item['rating'] as int) > 0 || (item['remarks'] as String).isNotEmpty);
    if (!hasAnyInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating or remarks for at least one item.')),
      );
      return;
    }

    try {
      // Use current date format YYYY-MM-DD
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final token = AuthService.token ?? '';
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/item-feedbacks/daily-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'employee_id': AuthService.employeeId,
          'canteen_id': AuthService.user?['canteen_id'] ?? 1,
          'date': dateStr,
          'items': feedbackItems
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [
              Icon(Icons.check_circle_rounded, color: _C.accent),
              SizedBox(width: 8),
              Flexible(
                child: Text("Chef's Notes Updated",
                    style: TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
              ),
            ]),
            content: const Text("Thanks for helping us cook up a better experience.",
                style: TextStyle(color: _C.sub, height: 1.7, fontSize: 14)),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Yum 😋',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit feedback')));
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: _C.primary))
        : CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: TopBar(title: 'Daily Menu Feedback')),
          if (_items.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: _TodaysMenuCard(items: _items, menuDate: _menuDate),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.lunchType == 'fruit' ? 'Rate Each Fruit' : 'Rate Each Item',
                      style: TextStyle(
                          color: _C.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Your feedback helps us serve you better.',
                      style: TextStyle(
                          color: _C.sub.withOpacity(0.85), fontSize: 13)),
                ],
              ),
            ),
          ),
          if (_items.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text("No menu available for today.", style: TextStyle(color: _C.sub))),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _RatingCard(
                  item: _items[i],
                  controller: _controllers[i],
                  onRatingChanged: (r) => setState(() => _items[i].rating = r),
                ),
              ),
              childCount: _items.length,
            ),
          ),
          if (_items.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: _SubmitButton(onPressed: _submit),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _FooterNotice(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysMenuCard extends StatelessWidget {
  final List<MenuItem> items;
  final String menuDate;
  const _TodaysMenuCard({required this.items, required this.menuDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _C.accent.withOpacity(0.09),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: _C.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Today's Menu",
                style: TextStyle(
                    color: _C.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            Text(menuDate,
                style: TextStyle(
                    color: _C.sub.withOpacity(0.9), fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((i) => _MenuChip(name: i.name)).toList(),
        ),
      ]),
    );
  }
}

class _MenuChip extends StatelessWidget {
  final String name;
  const _MenuChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: _C.accent.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFFF5F8FF),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FoodChipIcon(foodName: name),
        const SizedBox(width: 6),
        Text(name,
            style: const TextStyle(
                color: _C.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final MenuItem item;
  final TextEditingController controller;
  final ValueChanged<int> onRatingChanged;

  const _RatingCard({
    required this.item,
    required this.controller,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _C.accent.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          FoodIconBadge(foodName: item.name),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.name,
                style: const TextStyle(
                    color: _C.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
          Row(
            children: List.generate(5, (i) {
              final filled = i < item.rating;
              return GestureDetector(
                onTap: () => onRatingChanged(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 26,
                    color: filled ? _C.starFill : _C.starEmpty,
                  ),
                ),
              );
            }),
          ),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          style: const TextStyle(color: _C.primary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Remarks (optional)',
            hintStyle:
                TextStyle(color: _C.sub.withOpacity(0.6), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF5F8FF),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: const Color(0xFFCDD5E0).withOpacity(0.6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: _C.accent, width: 1.5),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
        label: const Text('Submit Feedback',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3FBF),
          elevation: 4,
          shadowColor: _C.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _FooterNotice extends StatelessWidget {
  const _FooterNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.accent.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.shield_outlined, color: _C.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your feedback matters!',
                    style: TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                    "It's anonymous and helps us improve the quality of meals",
                    style: TextStyle(
                        color: _C.sub.withOpacity(0.9), fontSize: 12)),
              ]),
        ),
      ]),
    );
  }
}
