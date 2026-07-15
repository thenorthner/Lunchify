import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'auth_service.dart';

class AdminPendingRequestsPage extends StatefulWidget {
  const AdminPendingRequestsPage({super.key});

  @override
  State<AdminPendingRequestsPage> createState() => _AdminPendingRequestsPageState();
}

class _AdminPendingRequestsPageState extends State<AdminPendingRequestsPage> {
  List<Map<String, dynamic>> fruitRequests = [];
  List<Map<String, dynamic>> foodRequests = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchAllRequests();
  }

  Future<void> _fetchAllRequests() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final headers = {
        'Authorization': 'Bearer ${AuthService.token}',
      };

      final fruitRes = await http.get(Uri.parse(AppConfig.fruitLunchOrdersDetails), headers: headers);
      final foodRes = await http.get(Uri.parse(AppConfig.foodLunchOrdersDetails), headers: headers);

      if (fruitRes.statusCode == 200 && foodRes.statusCode == 200) {
        final List<dynamic> fruitJson = json.decode(fruitRes.body);
        final List<dynamic> foodJson = json.decode(foodRes.body);

        setState(() {
          fruitRequests = fruitJson.cast<Map<String, dynamic>>();
          foodRequests = foodJson.cast<Map<String, dynamic>>();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load requests: Fruit ${fruitRes.statusCode}, Food ${foodRes.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  Future<void> _updateStatus(String type, int id, String status) async {
    final baseUrl = '${AppConfig.apiBaseUrl}/api/${type == 'fruit' ? 'fruit-lunch-orders' : 'food-lunch-orders'}/$id/status';

    try {
      final res = await http.patch(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: json.encode({'status': status}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $status')),
        );
        await _fetchAllRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<Widget> _buildItemsList(dynamic itemsData) {
    List<dynamic> items = [];
    if (itemsData is String) {
      try {
        items = json.decode(itemsData);
      } catch (e) {
        return [Text(itemsData.toString())];
      }
    } else if (itemsData is List) {
      items = itemsData;
    }

    return items.map((item) {
      final name = item['name'] ?? 'Unknown Item';
      final q = item['quantity']?.toString() ?? '1';
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            const Icon(Icons.arrow_right, size: 16, color: Color(0xFF8A96A8)),
            const SizedBox(width: 4),
            Text(
              "${q}x $name",
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A2340)),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCard(Map<String, dynamic> order, String type) {
    final id = order['id'];
    final name = order['employee_name'] ?? 'Unknown Employee';
    final itemName = order['item_name'] ?? order['name'] ?? (type == 'food' ? 'Food Lunch' : 'Fruit Lunch');
    final empId = order['employee_id'] ?? 'N/A';
    final qty = order['quantity']?.toString() ?? '1';
    final date = order['date'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A8F).withOpacity(0.06), // kPrimaryBlue
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFF0F5FB), // kSubtle
                  child: Icon(
                    type == 'fruit' ? Icons.eco : Icons.restaurant,
                    color: const Color(0xFF1A3A8F), // kPrimaryBlue
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1A2E6E), // kNavy
                        ),
                      ),
                      Text(
                        "Emp ID: $empId • Item: $itemName",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A96A8), // kGray
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Qty: $qty",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A8F),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFDCE8F5)), // kBorder
            
            if (order['items'] != null) ...[
              const Text("Selected Items:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2E6E))),
              const SizedBox(height: 8),
              ..._buildItemsList(order['items']),
              const Divider(height: 24, color: Color(0xFFDCE8F5)),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: Text("Date: $date", style: const TextStyle(fontSize: 13, color: Color(0xFF8A96A8))),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(type, id, 'accepted'),
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: const Text("Accept", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A8F), // kPrimaryBlue
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(type, id, 'rejected'),
                    icon: const Icon(Icons.close, color: Color(0xFFE53935), size: 18), // Red
                    label: const Text("Reject", style: TextStyle(color: Color(0xFFE53935))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53935)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool noRequests = fruitRequests.isEmpty && foodRequests.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FB), // kSubtle
            body: Column(
        children: [
          _TopBar(title: 'Pending Lunch Approvals', onRefresh: _fetchAllRequests),
          Expanded(
            child: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3A8F)))
          : error != null
          ? Center(child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 16)))
          : noRequests
          ? const Center(child: Text('No pending lunch approvals for today.', style: TextStyle(fontSize: 16, color: Color(0xFF8A96A8))))
          : RefreshIndicator(
        onRefresh: _fetchAllRequests,
        child: ListView(
          children: [
            if (fruitRequests.isNotEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Fruit Lunch Orders',
                  style: TextStyle(color: Color(0xFF1A2E6E), fontWeight: FontWeight.w800, fontSize: 22),
                ),
              ),
            ...fruitRequests.map((o) => _buildCard(o, 'fruit')),
            if (foodRequests.isNotEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 32, 16, 8),
                child: Text(
                  'Food Lunch Orders',
                  style: TextStyle(color: Color(0xFF1A2E6E), fontWeight: FontWeight.w800, fontSize: 22),
                ),
              ),
              ...foodRequests.map((o) => _buildCard(o, 'food')),
            ],
          ),
        ),
      ),
      ],
      ),
      );
    }
  }


// --- Top Bar ------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  const _TopBar({required this.title, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color(0xFFD0DCF0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 38),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2E6E),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF1A2E6E)),
                    onPressed: onRefresh,
                    tooltip: "Refresh list",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Animated Back Button -----------------------------------------------------
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
    _slide = Tween<double>(begin: 0, end: -4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
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
                    color: const Color(0xFF1A2E6E).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF1A2E6E), size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

