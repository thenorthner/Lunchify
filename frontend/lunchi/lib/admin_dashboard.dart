import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'qr_scanner.dart';
import 'menu_setup_page.dart';
import 'fruit_lunch_requests_page.dart';
import 'snacks_orders_page.dart';
import 'login_page.dart';
import 'config.dart';
import 'auth_service.dart';
import 'admin_billing_page.dart';

class AdminDashboard extends StatefulWidget {
  final String adminName;
  final String jwtToken;

  const AdminDashboard({
    super.key,
    required this.adminName,
    required this.jwtToken,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalFruitRequests = 0;
  int totalCouponsCollected = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => isLoading = true);

    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/fruit-lunch-requests'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          totalFruitRequests = data['fruitRequests'] ?? 0;
          totalCouponsCollected = data['couponsCollected'] ?? 0;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load dashboard data");
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const whiteText = Colors.white;
    const cardRadius = 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/admin_avatar.png'),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Text(
              "Hi, ${widget.adminName}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/admin_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.55)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Fruit Requests",
                            "$totalFruitRequests",
                            Icons.local_florist,
                            Colors.green.shade600,
                            Colors.green.shade100.withOpacity(0.7),
                            cardRadius,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            "Coupons Collected",
                            "$totalCouponsCollected",
                            Icons.confirmation_num,
                            Colors.deepOrange,
                            Colors.orange.shade100.withOpacity(0.7),
                            cardRadius,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Admin Tools',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionGrid(cardRadius),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor,
      Color bgColor, double radius) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(double cardRadius) {
    final actions = [
      {
        'label': 'Setup Menu',
        'icon': Icons.restaurant_menu,
        'color': Colors.deepOrange,
        'page': const MenuSetupPage(),
      },
      {
        'label': 'Fruit Lunch Requests',
        'icon': Icons.local_florist,
        'color': Colors.green,
        'page': const FruitLunchRequestsPage(),
      },
      {
        'label': 'Snacks Orders',
        'icon': Icons.fastfood,
        'color': Colors.brown,
        'page': const SnackOrderPage(),
      },
      {
        'label': 'Scan QR',
        'icon': Icons.qr_code_scanner,
        'color': Colors.blue,
        'page': QRScannerPage(scannerId: widget.adminName),
      },
      {
        'label': 'Generate Bill',
        'icon': Icons.receipt_long,
        'color': Colors.purple,
        'page': const AdminBillingPage(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        final Color itemColor = item['color'] as Color;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            gradient: LinearGradient(
              colors: [
                itemColor.withOpacity(0.9),
                itemColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: itemColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(cardRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(cardRadius),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['page'] as Widget),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData, size: 36, color: Colors.white),
                    const SizedBox(height: 14),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
