//snack_order_history_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'config.dart';
import 'auth_service.dart';
import 'widgets/top_bar.dart';

class SnackOrderHistoryPage extends StatefulWidget {
  final String employeeId;

  const SnackOrderHistoryPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<SnackOrderHistoryPage> createState() => _SnackOrderHistoryPageState();
}

class _SnackOrderHistoryPageState extends State<SnackOrderHistoryPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  String _selectedFilter = 'all'; // all | pending | accepted | delivered | cancelled
  DateTime? _selectedDate;
  DateTime? _selectedMonth;
  int? _selectedYear;
  bool _sortNewest = true;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _ordersFuture = _fetchHistory();
    });
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

  Future<List<Map<String, dynamic>>> _fetchHistory() async {
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final parsed = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF1A2340), // kDarkText
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF1A3A8F), // kPrimaryBlue
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF1A3A8F) : const Color(0xFFDCE8F5), // kBorder
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        label = 'Pending';
        break;
      case 'accepted':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF1A7A4E); // kGreen
        label = 'Accepted';
        break;
      case 'delivered':
        bg = const Color(0xFFEAF2FF);
        fg = const Color(0xFF2563EB); // kAccentBlue
        label = 'Delivered';
        break;
      case 'cancelled':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFE53935); // kRedAccent
        label = 'Cancelled';
        break;
      default:
        bg = Colors.grey.shade50;
        fg = Colors.grey.shade800;
        label = status;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FB), // kSubtle
      body: Column(
        children: [
          const TopBar(title: "Snack Order History"),
          
          // FILTERS HORIZONTAL LIST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All Orders", "all"),
                  _buildFilterChip("Pending", "pending"),
                  _buildFilterChip("Accepted", "accepted"),
                  _buildFilterChip("Delivered", "delivered"),
                  _buildFilterChip("Cancelled", "cancelled"),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _sortNewest ? 'newest' : 'oldest',
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Sort: Newest')),
                    DropdownMenuItem(value: 'oldest', child: Text('Sort: Oldest')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _sortNewest = v == 'newest');
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _selectedYear,
                    hint: const Text('Year'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('All Years')),
                      ...List.generate(5, (i) => DateTime.now().year - i)
                          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))),
                    ],
                    onChanged: (v) => setState(() => _selectedYear = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _selectedMonth?.month,
                    hint: const Text('Month'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('All Months')),
                      ...List.generate(12, (i) => i + 1)
                          .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMM').format(DateTime(2020, m))))),
                    ],
                    onChanged: (v) {
                       setState(() {
                         if (v == null) _selectedMonth = null;
                         else _selectedMonth = DateTime(DateTime.now().year, v);
                       });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // HISTORY ITEMS LIST
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF1A3A8F), // kPrimaryBlue
              onRefresh: () async {
                _refreshHistory();
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1A3A8F)),
                    );
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Container(
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
                      ],
                    );
                  }

                  final allOrders = snapshot.data ?? [];

                  // Apply filter
                  var filteredOrders = allOrders.where((order) {
                    if (_selectedFilter != 'all') {
                      final status = (order['status'] ?? '').toString().toLowerCase();
                      if (status != _selectedFilter) return false;
                    }
                    if (_selectedDate != null || _selectedMonth != null || _selectedYear != null) {
                      final dateStr = order['created_at'];
                      if (dateStr == null) return false;
                      try {
                        final date = DateTime.parse(dateStr).toLocal();
                        if (_selectedDate != null) {
                          if (date.year != _selectedDate!.year || date.month != _selectedDate!.month || date.day != _selectedDate!.day) return false;
                        } else if (_selectedMonth != null) {
                          if (date.year != _selectedMonth!.year || date.month != _selectedMonth!.month) return false;
                        } else if (_selectedYear != null) {
                          if (date.year != _selectedYear) return false;
                        }
                      } catch (_) { return false; }
                    }
                    return true;
                  }).toList();
                  
                  filteredOrders.sort((a, b) {
                     final d1 = a['created_at'] != null ? DateTime.tryParse(a['created_at']) : null;
                     final d2 = b['created_at'] != null ? DateTime.tryParse(b['created_at']) : null;
                     if (d1 == null || d2 == null) return 0;
                     return _sortNewest ? d2.compareTo(d1) : d1.compareTo(d2);
                  });

                  if (filteredOrders.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_toggle_off,
                                size: 70,
                                color: const Color(0xFF1A3A8F).withOpacity(0.3), // kPrimaryBlue
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == 'all'
                                    ? "No snack orders found."
                                    : "No ${_selectedFilter} snack orders.",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2E6E), // kNavy
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Swipe down to refresh.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A96A8), // kGray
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final items = _parseItemsList(order['items']);
                      final status = (order['status'] ?? 'pending').toString();
                      final total = order['total'] ?? 0;
                      final session = (order['session'] ?? 'morning').toString();
                      final timestamp = _formatDateTime(order['created_at']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          timestamp,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF5A7CC9), // kSubtext
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Session: ${session.toUpperCase()}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A2E6E), // kNavy
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(status),
                                ],
                              ),
                              const Divider(height: 20, color: Color(0xFFDCE8F5)), // kBorder
                              ...items.map<Widget>((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
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
                              const Divider(height: 20, color: Color(0xFFDCE8F5)), // kBorder
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Paid:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A2E6E), // kNavy
                                    ),
                                  ),
                                  Text(
                                    "₹$total",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB), // kAccentBlue
                                    ),
                                  ),
                                ],
                              ),
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
