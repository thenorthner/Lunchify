//snack_order_status_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'auth_service.dart';
import 'widgets/top_bar.dart';

class SnackOrderStatusPage extends StatefulWidget {
  final String employeeId;

  const SnackOrderStatusPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<SnackOrderStatusPage> createState() => _SnackOrderStatusPageState();
}

class _SnackOrderStatusPageState extends State<SnackOrderStatusPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  List<dynamic> _decodeJsonListOrThrow(http.Response res, {String? hint}) {
    final raw = res.body.trimLeft();

    if (raw.startsWith('<')) {
      throw Exception('${hint ?? "API"} returned HTML instead of JSON');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('${hint ?? "API"} failed (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded;

    throw Exception('${hint ?? "API"} expected a JSON list');
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final response = await http.get(
      Uri.parse('${AppConfig.snackOrders}?employeeId=${widget.employeeId}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    final data = _decodeJsonListOrThrow(response, hint: 'Snack Orders');
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> _confirmReceived(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.snackOrders}/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({"status": "delivered"}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("🎉 Order marked as received and added to history!"),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          setState(() {
            _ordersFuture = _fetchOrders();
          });
        }
      } else {
        throw Exception("Failed to update order status (HTTP ${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: $e"),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  List<dynamic> _parseItemsList(dynamic itemsData) {
    if (itemsData == null) return [];
    if (itemsData is List) return itemsData;
    if (itemsData is String) {
      try {
        return jsonDecode(itemsData) as List;
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FB), // kSubtle
      body: Column(
        children: [
          const TopBar(title: "Active Snack Orders"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1A3A8F)));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          snapshot.error.toString(),
                          style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final allOrders = snapshot.data ?? [];
                  // Filter to show active orders only (pending or accepted)
                  final activeOrders = allOrders
                      .where((o) => o['status'] == 'pending' || o['status'] == 'accepted')
                      .toList();

                  if (activeOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 70,
                            color: const Color(0xFF1A7A4E).withOpacity(0.6), // kGreen
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No active snack orders!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2E6E), // kNavy
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "All your orders have been received and recorded.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A96A8), // kGray
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: activeOrders.length,
                    itemBuilder: (context, index) {
                      final order = activeOrders[index];
                      final items = _parseItemsList(order['items']);
                      final status = order['status'] ?? 'pending';
                      final total = order['total'] ?? 0;
                      final id = order['id'];
                      final session = order['session'] ?? 'morning';

                      final isAccepted = status == 'accepted';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A3A8F).withOpacity(0.06), // kPrimaryBlue
                              blurRadius: 16,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isAccepted ? const Color(0xFFE8F5E9) : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isAccepted ? Colors.green.shade200 : Colors.orange.shade200,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Text(
                                      isAccepted ? "● Accepted" : "● Pending",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: isAccepted ? const Color(0xFF1A7A4E) : Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF2FF), // kBgColor
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    child: Text(
                                      session.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A2E6E), // kNavy
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, color: Color(0xFFDCE8F5)), // kBorder
                              ...items.map<Widget>((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${item['snack'] ?? 'Snack'} × ${item['quantity'] ?? 1}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A2340), // kDarkText
                                        ),
                                      ),
                                      Text(
                                        "₹${item['cost'] ?? 0}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF5A7CC9), // kSubtext
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(height: 24, color: Color(0xFFDCE8F5)), // kBorder
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A2E6E), // kNavy
                                    ),
                                  ),
                                  Text(
                                    "₹$total",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB), // kAccentBlue
                                    ),
                                  ),
                                ],
                              ),
                              if (isAccepted && id != null) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                    label: const Text(
                                      "Mark as received",
                                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A7A4E), // kGreen
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _confirmReceived(id),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
