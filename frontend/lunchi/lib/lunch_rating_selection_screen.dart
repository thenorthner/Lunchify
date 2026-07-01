import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';
import 'daily_menu_feedback_screen.dart';
import 'app_theme.dart';

class LunchRatingSelectionScreen extends StatefulWidget {
  const LunchRatingSelectionScreen({super.key});

  @override
  State<LunchRatingSelectionScreen> createState() =>
      _LunchRatingSelectionScreenState();
}

class _LunchRatingSelectionScreenState
    extends State<LunchRatingSelectionScreen> {
  bool _isLoading = true;
  bool _foodScanned = false;
  bool _fruitScanned = false;

  @override
  void initState() {
    super.initState();
    _fetchTodayStatus();
  }

  Future<void> _fetchTodayStatus() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/qr/my-status-today'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _foodScanned = data['foodScanned'] ?? false;
          _fruitScanned = data['fruitScanned'] ?? false;
          _isLoading = false;
        });

        if (!_foodScanned && !_fruitScanned) {
          _showNotScannedDialog();
        }
      } else {
        throw Exception('Failed to fetch status');
      }
    } catch (e) {
      debugPrint("❌ Error fetching today status: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showNotScannedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        title: const Text(
          'Hold up! 🛑',
          style: TextStyle(
            color: kPrimaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          "Can't review what you didn't chew😋. Purchase required to unlock opinions.",
          style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Alright Chief 🫡',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLunchTypeSelected(String type, bool isScanned) {
    if (!isScanned) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          title: const Text(
            'Hold up! 🛑',
            style: TextStyle(
              color: kPrimaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: const Text(
            "Ain't no way you're rating imaginary food, Scan the coupon and we'll talk 😤.",
            style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Alright Chief 🫡',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
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
        builder: (_) => DailyMenuFeedbackScreen(lunchType: type),
      ),
    );
  }

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
      appBar: AppBar(
        title: const Text(
          "Select Lunch to Rate",
          style: TextStyle(fontWeight: FontWeight.w800, color: kPrimaryBlue),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryBlue),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MenuOptionCard(
                title: "Fruit Lunch",
                subtitle: "Rate your healthy & fresh options",
                icon: Icons.local_cafe_rounded, // Similar to fruit lunch icon
                isActive: _fruitScanned,
                onTap: () => _onLunchTypeSelected('fruit', _fruitScanned),
              ),
              const SizedBox(height: 16),
              _MenuOptionCard(
                title: "Food Lunch",
                subtitle: "Rate today's main food lunch",
                icon: Icons.restaurant_rounded, // Similar to food lunch icon
                isActive: _foodScanned,
                onTap: () => _onLunchTypeSelected('food', _foodScanned),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOptionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_MenuOptionCard> createState() => _MenuOptionCardState();
}

class _MenuOptionCardState extends State<_MenuOptionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: widget.isActive ? 1.0 : 0.6, // Dim if not scanned
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kLightBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: kPrimaryBlue, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kPrimaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kSubtext,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: kAccentBlue,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
