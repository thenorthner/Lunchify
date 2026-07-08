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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with blue shield
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Little blue burst lines
                  Positioned(top: 25, left: 40, child: Transform.rotate(angle: -0.5, child: Container(width: 2, height: 8, color: const Color(0xFF3B82F6)))),
                  Positioned(top: 40, left: 30, child: Transform.rotate(angle: -1.0, child: Container(width: 2, height: 8, color: const Color(0xFF3B82F6)))),
                  Positioned(top: 55, left: 40, child: Transform.rotate(angle: -1.5, child: Container(width: 2, height: 8, color: const Color(0xFF3B82F6)))),
                  
                  Positioned(top: 25, right: 40, child: Transform.rotate(angle: 0.5, child: Container(width: 2, height: 8, color: const Color(0xFF3B82F6)))),
                  Positioned(top: 40, right: 30, child: Transform.rotate(angle: 1.0, child: Container(width: 2, height: 8, color: const Color(0xFF3B82F6)))),
                  Positioned(top: 55, right: 40, child: Transform.rotate(angle: 1.5, child: Container(width: 2, height: 8, color: const Color(0xFF3B82F6)))),
                  
                  // Main circle
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDBEAFE).withOpacity(0.8),
                    ),
                    child: Center(
                      child: Container(
                        width: 56, height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB), // Blue shield color
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded, // Shield with check
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm Order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A), // kNavy
              ),
            ),
            const SizedBox(height: 16),
            
            // Divider with verified badge
            Row(
              children: [
                Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Icon(Icons.verified, size: 20, color: Color(0xFF2563EB)),
                ),
                Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
              ],
            ),
            
            const SizedBox(height: 16),
            const Text(
              'One step closer to a well-earned lunch!\n😋 Secure your lunch now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Secure Lunch',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with glowing check & sparkles
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Little green burst lines
                      Positioned(top: 25, left: 40, child: Transform.rotate(angle: -0.5, child: Container(width: 2, height: 8, color: const Color(0xFF22C55E)))),
                      Positioned(top: 40, left: 30, child: Transform.rotate(angle: -1.0, child: Container(width: 2, height: 8, color: const Color(0xFF22C55E)))),
                      Positioned(top: 55, left: 40, child: Transform.rotate(angle: -1.5, child: Container(width: 2, height: 8, color: const Color(0xFF22C55E)))),
                      
                      Positioned(top: 25, right: 40, child: Transform.rotate(angle: 0.5, child: Container(width: 2, height: 8, color: const Color(0xFF22C55E)))),
                      Positioned(top: 40, right: 30, child: Transform.rotate(angle: 1.0, child: Container(width: 2, height: 8, color: const Color(0xFF22C55E)))),
                      Positioned(top: 55, right: 40, child: Transform.rotate(angle: 1.5, child: Container(width: 2, height: 8, color: const Color(0xFF22C55E)))),
                      
                      // Soft glow behind the circle
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF22C55E).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      
                      // Main circle with gradient
                      Container(
                        width: 64, height: 64,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Lunch Stash Secured! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E3A8A), // kNavy
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Divider with shield
                Row(
                  children: [
                    Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Icon(Icons.verified, size: 20, color: Color(0xFF22C55E)),
                    ),
                    Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                const Text(
                  'Freshness incoming.\nStay tuned 😎',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A8F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Alright 👍',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
