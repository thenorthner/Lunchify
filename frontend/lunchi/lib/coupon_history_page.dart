import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Widget _buildIconForType(String type, Color color) {
    if (type == 'lunch') return const Text('🍱', style: TextStyle(fontSize: 24));
    if (type == 'fruit') return const Text('🍎', style: TextStyle(fontSize: 24));
    if (type == 'sharing') return Icon(Icons.send_rounded, color: color);
    return Icon(Icons.confirmation_number_rounded, color: color);
  }

  Color _getColorForType(String type) {
    if (type == 'lunch') return const Color(0xFFF59E0B); // Orange
    if (type == 'fruit') return const Color(0xFF10B981); // Green
    if (type == 'sharing') return const Color(0xFF3B82F6); // Blue
    return kPrimaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Usage History"),
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
                      : _history.isEmpty
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
                                  const Text(
                                    "No coupon usage history found.",
                                    style: TextStyle(
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
                                itemCount: _history.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _history[index];
                                  final date = DateTime.parse(item['used_at']);
                                  final formattedDate = DateFormat('MMM d, yyyy • hh:mm a').format(date);

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
                                            color: _getColorForType(item['usage_type']).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: _buildIconForType(
                                              item['usage_type'],
                                              _getColorForType(item['usage_type']),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['description'] ?? 'Used Coupon',
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
                                              "-${item['amount']}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: kRed,
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
