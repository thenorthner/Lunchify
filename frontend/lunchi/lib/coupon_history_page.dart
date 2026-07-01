import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'package:intl/intl.dart';
import 'config.dart';
import 'auth_service.dart';
import 'app_theme.dart';
import 'widgets/top_bar.dart';

class CouponHistoryPage extends StatefulWidget {
  final String employeeId;

  const CouponHistoryPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<CouponHistoryPage> createState() => _CouponHistoryPageState();
}

class _CouponHistoryPageState extends State<CouponHistoryPage> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _history = [];
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'used', 'label': 'Used'},
    {'key': 'received', 'label': 'Received'},
    {'key': 'shared', 'label': 'Shared'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/coupons/history/${widget.employeeId}'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _history = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredHistory {
    if (_selectedFilter == 'all') return _history;
    if (_selectedFilter == 'used') {
      return _history.where((item) =>
        item['usage_type'] == 'lunch' || item['usage_type'] == 'fruit'
      ).toList();
    }
    if (_selectedFilter == 'received') {
      return _history.where((item) => item['usage_type'] == 'received').toList();
    }
    if (_selectedFilter == 'shared') {
      return _history.where((item) => item['usage_type'] == 'sharing').toList();
    }
    return _history;
  }

  // Summary counts
  int get _totalUsed => _history
      .where((i) => i['usage_type'] == 'lunch' || i['usage_type'] == 'fruit')
      .fold(0, (sum, i) => sum + (int.tryParse(i['amount'].toString()) ?? 0));

  int get _totalReceived => _history
      .where((i) => i['usage_type'] == 'received')
      .fold(0, (sum, i) => sum + (int.tryParse(i['amount'].toString()) ?? 0));

  int get _totalShared => _history
      .where((i) => i['usage_type'] == 'sharing')
      .fold(0, (sum, i) => sum + (int.tryParse(i['amount'].toString()) ?? 0));

  Widget _buildIconForType(String type, Color color) {
    if (type == 'lunch') return const Text('🍱', style: TextStyle(fontSize: 24));
    if (type == 'fruit') return const Text('🍎', style: TextStyle(fontSize: 24));
    if (type == 'sharing') return Icon(Icons.send_rounded, color: color);
    if (type == 'received') return const Text('🎁', style: TextStyle(fontSize: 24));
    return Icon(Icons.confirmation_number_rounded, color: color);
  }

  Color _getColorForType(String type) {
    if (type == 'lunch') return const Color(0xFFF59E0B); // Orange
    if (type == 'fruit') return const Color(0xFF10B981); // Green
    if (type == 'sharing') return const Color(0xFF3B82F6); // Blue
    if (type == 'received') return const Color(0xFF8B5CF6); // Purple
    return kPrimaryBlue;
  }

  String _getLabelForType(String type) {
    if (type == 'lunch') return 'Lunch Coupon Used';
    if (type == 'fruit') return 'Fruit Coupon Used';
    if (type == 'sharing') return 'Coupon Shared';
    if (type == 'received') return 'Coupon Received';
    return 'Coupon Used';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHistory;

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Coupon History"),

            // Summary Cards Row
            if (!_isLoading && _error == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _SummaryChip(label: 'Used', count: _totalUsed, color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    _SummaryChip(label: 'Received', count: _totalReceived, color: const Color(0xFF8B5CF6)),
                    const SizedBox(width: 8),
                    _SummaryChip(label: 'Shared', count: _totalShared, color: const Color(0xFF3B82F6)),
                  ],
                ),
              ),

            // Filter Chips
            if (!_isLoading && _error == null)
              SizedBox(
                height: 36, // Reduced height to make buttons less thick
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter['key'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter['key']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center, // Centers text both vertically and horizontally
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? kPrimaryBlue : const Color(0xFFE0E7F1),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: kPrimaryBlue.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          filter['label']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isSelected ? Colors.white : kNavy,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: kRed),
                          ),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 64,
                                    color: kSubtext.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedFilter == 'all'
                                        ? "No coupon history found."
                                        : "No ${_filters.firstWhere((f) => f['key'] == _selectedFilter)['label']?.toLowerCase()} coupons found.",
                                    style: const TextStyle(
                                      color: kNavy,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchHistory,
                              color: kPrimaryBlue,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final date = DateTime.parse(item['used_at']);
                                  final formattedDate = DateFormat('MMM d, yyyy • hh:mm a').format(date);
                                  final type = item['usage_type'] ?? 'lunch';

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kPrimaryBlue.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _getColorForType(type).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: _buildIconForType(
                                              type,
                                              _getColorForType(type),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['description'] ?? _getLabelForType(type),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: kNavy,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: kSubtext,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              "Coupons",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: kSubtext,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              type == 'received' ? "+${item['amount']}" : "-${item['amount']}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: type == 'received' ? Colors.green : kRed,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Determine icon based on label
    IconData iconData = Icons.local_activity_rounded;
    if (label == 'Used') iconData = Icons.restaurant_rounded;
    if (label == 'Received') iconData = Icons.card_giftcard_rounded;
    if (label == 'Shared') iconData = Icons.share_rounded;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
