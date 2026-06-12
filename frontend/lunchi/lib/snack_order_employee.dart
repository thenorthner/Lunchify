//snack_order_employee.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'snack_order_status_page.dart';
import 'config.dart';
import 'auth_service.dart';
import 'widgets/top_bar.dart';

class EmployeeSnackOrderPage extends StatefulWidget {
  final String employeeId;

  const EmployeeSnackOrderPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<EmployeeSnackOrderPage> createState() => _EmployeeSnackOrderPageState();
}

class _EmployeeSnackOrderPageState extends State<EmployeeSnackOrderPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _session = 'morning'; // morning | evening

  List<String> _availableSnacks = [];
  Map<String, String> _snackEmojis = {};
  Map<String, int> _snackCosts = {};
  final Map<String, int> _selectedSnacks = {};

  @override
  void initState() {
    super.initState();
    _loadAvailableSnacks();
  }

  String _today() {
    final d = DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadAvailableSnacks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(AppConfig.snacksMenu(_today(), _session)),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          _availableSnacks = data.map((e) => e['name'] as String).toList();

          _snackEmojis = {
            for (var s in data) s['name']: s['emoji'] ?? '🍴'
          };

          _snackCosts = {
            for (var s in data) s['name']: s['cost'] ?? 15
          };

          _selectedSnacks.clear();
        });
      } else {
        throw Exception("Failed to load snacks menu");
      }
    } catch (e) {
      _showError("Error loading snacks menu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  int _calculateTotalPrice() {
    return _selectedSnacks.entries.fold(
      0,
      (sum, e) => sum + (_snackCosts[e.key] ?? 0) * e.value,
    );
  }

  Future<void> _submitOrder() async {
    if (_selectedSnacks.isEmpty) {
      _showError("Select at least one snack item to order.");
      return;
    }

    final items = _selectedSnacks.entries.map((e) {
      return {
        "snack": e.key,
        "quantity": e.value,
        "cost": (_snackCosts[e.key] ?? 0) * e.value,
      };
    }).toList();

    try {
      setState(() => _isSubmitting = true);

      final res = await http.post(
        Uri.parse(AppConfig.snackOrders),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          "employeeId": widget.employeeId,
          "roomId": null,
          "session": _session,
          "items": items,
          "total": _calculateTotalPrice(),
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("🎉 Snack order placed successfully!"),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SnackOrderStatusPage(employeeId: widget.employeeId),
            ),
          );
        }
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      _showError("Failed to submit order: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _sessionToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE8F5)), // kBorder
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _session = 'morning');
                _loadAvailableSnacks();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _session == 'morning' ? const Color(0xFF1A3A8F) : Colors.transparent, // kPrimaryBlue
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  "☀️ Morning Snacks",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _session == 'morning' ? Colors.white : const Color(0xFF1A2340), // kDarkText
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _session = 'evening');
                _loadAvailableSnacks();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _session == 'evening' ? const Color(0xFF1A3A8F) : Colors.transparent, // kPrimaryBlue
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  "🌙 Evening Snacks",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _session == 'evening' ? Colors.white : const Color(0xFF1A2340), // kDarkText
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnackCard(String snack) {
    final qty = _selectedSnacks[snack] ?? 0;
    final emoji = _snackEmojis[snack] ?? '🍴';
    final price = _snackCosts[snack] ?? 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF), // kBgColor
                borderRadius: BorderRadius.circular(12),
              ),
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snack,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2E6E), // kNavy
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹$price",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2563EB), // kAccentBlue
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: qty > 0 ? const Color(0xFFEAF2FF) : const Color(0xFFF0F5FB), // kBgColor / kSubtle
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Color(0xFF1A3A8F)), // kPrimaryBlue
                    onPressed: qty > 0
                        ? () => setState(() =>
                            qty == 1 ? _selectedSnacks.remove(snack) : _selectedSnacks[snack] = qty - 1)
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    '$qty',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2340), // kDarkText
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF), // kBgColor
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF1A3A8F)), // kPrimaryBlue
                    onPressed: () => setState(() => _selectedSnacks[snack] = qty + 1),
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
    final total = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FB), // kSubtle
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Order Snacks"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    _sessionToggle(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3A8F)))
                          : _availableSnacks.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 70,
                                        color: const Color(0xFF1A3A8F).withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "No snacks menu set for this session today.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A2E6E), // kNavy
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        "Please check back later or contact canteen admin.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8A96A8), // kGray
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView(
                                  children: _availableSnacks.map(_buildSnackCard).toList(),
                                ),
                    ),
                    const SizedBox(height: 16),
  
                    // Total & Note Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A3A8F).withOpacity(0.06), // kPrimaryBlue
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Amount:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2E6E), // kNavy
                                ),
                              ),
                              Text(
                                "₹$total",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2563EB), // kAccentBlue
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFDCE8F5)), // kBorder
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: Color(0xFF5A7CC9)), // kSubtext
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Note: Snacks are pickup only. Pay directly at the counter. Order details are saved to history.",
                                  style: TextStyle(
                                    color: const Color(0xFF5A7CC9), // kSubtext
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
  
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _availableSnacks.isEmpty || _isSubmitting) ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A8F), // kPrimaryBlue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text(
                                "Submit Order",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
