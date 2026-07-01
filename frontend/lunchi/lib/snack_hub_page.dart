import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'auth_service.dart';
import 'config.dart';
import 'snack_order_employee.dart';
import 'snack_order_history_page.dart';
import 'snack_order_status_page.dart';
import 'widgets/top_bar.dart';

class SnackHubPage extends StatefulWidget {
  final String employeeId;

  const SnackHubPage({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<SnackHubPage> createState() => _SnackHubPageState();
}

class _SnackHubPageState extends State<SnackHubPage> {
  bool _isLoading = false;

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeCabinFoodLunchOrder() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text(
          'One step closer to a well-earned lunch 😋. Secure Your Lunch!',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3A8F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Secure Lunch',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final resp = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/food-lunch/order-food-lunch'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'name': 'Cabin Food Lunch',
          'quantity': 1,
          'order_type': 'cabin',
        }),
      );

      if (resp.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Expanded(child: Text('Lunch Stash Secured ✨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ],
            ),
            content: const Text(
              'Freshness incoming. Stay tuned 😎',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A8F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Alright 👍',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        final body = jsonDecode(resp.body);
        _showInfoDialog(
          'Failed',
          body['error'] ?? body['message'] ?? 'Could not place order.',
        );
      }
    } catch (e) {
      _showInfoDialog('Error', 'Request failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kBgColor = Color(0xFFF8FAFC);
    const Color kPrimaryBlue = Color(0xFF1A3A8F);

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Canteen Hub"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _HubCard(
                      icon: Icons.lunch_dining_rounded,
                      title: "Order Cabin Food Lunch",
                      subtitle: "Order food lunch to your cabin",
                      isLoading: _isLoading,
                      onTap: _isLoading ? () {} : _placeCabinFoodLunchOrder,
                    ),
                    const SizedBox(height: 20),
                    _HubCard(
                      icon: Icons.room_service_rounded,
                      title: "Order Snacks",
                      subtitle: "Order your favorite snacks",
                      onTap: _isLoading
                          ? () {}
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EmployeeSnackOrderPage(
                                  employeeId: widget.employeeId,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),
                    _HubCard(
                      icon: Icons.history_rounded,
                      title: "Order History",
                      subtitle: "View your past snack orders",
                      onTap: _isLoading
                          ? () {}
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SnackOrderHistoryPage(
                                  employeeId: widget.employeeId,
                                ),
                              ),
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

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A3A8F).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF1A3A8F)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2E6E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8A96A8),
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A3A8F),
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF8A96A8),
                  ),
          ],
        ),
      ),
    );
  }
}
