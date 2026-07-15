import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'auth_service.dart';
import 'config.dart';
import 'widgets/top_bar.dart';

class AdminScanHistoryPage extends StatefulWidget {
  const AdminScanHistoryPage({Key? key}) : super(key: key);

  @override
  State<AdminScanHistoryPage> createState() => _AdminScanHistoryPageState();
}

class _AdminScanHistoryPageState extends State<AdminScanHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _logs = [];

  // Filter state
  final TextEditingController _empIdCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchScanLogs();
  }

  Future<void> _fetchScanLogs() async {
    final token = AuthService.token;
    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      String url = '${AppConfig.apiBaseUrl}/api/qr/scan-logs?';
      if (_empIdCtrl.text.isNotEmpty) {
        url += 'employee_id=${_empIdCtrl.text.trim()}&';
      }
      if (_selectedDate != null) {
        url += 'date=${DateFormat('yyyy-MM-dd').format(_selectedDate!)}&';
      } else if (_selectedMonth != null) {
        url += 'month=$_selectedMonth&';
      }

      final res = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _logs = jsonDecode(res.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching scan logs: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedMonth = null; // Clear month if specific date is chosen
      });
      _fetchScanLogs();
    }
  }

  void _clearFilters() {
    setState(() {
      _empIdCtrl.clear();
      _selectedDate = null;
      _selectedMonth = null;
    });
    _fetchScanLogs();
  }

  @override
  Widget build(BuildContext context) {
    const kBg = Color(0xFFF8FAFC);
    const kNavy = Color(0xFF0F172A);
    const kAccent = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          TopBar(
            title: "Scan History",
            action: IconButton(
              icon: const Icon(Icons.refresh, color: kNavy),
              onPressed: _fetchScanLogs,
            ),
          ),
          const SizedBox(height: 16),
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _empIdCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Filter by Emp ID',
                            hintStyle: TextStyle(fontSize: 13),
                            prefixIcon: Icon(Icons.badge_outlined, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => _fetchScanLogs(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.calendar_today_outlined, size: 20),
                        color: _selectedDate != null ? kAccent : Colors.grey,
                        onPressed: _pickDate,
                      ),
                    ),
                  ],
                ),
                if (_selectedDate != null || _empIdCtrl.text.isNotEmpty || _selectedMonth != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        if (_selectedDate != null)
                          Chip(
                            label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate!), style: const TextStyle(fontSize: 11)),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              setState(() => _selectedDate = null);
                              _fetchScanLogs();
                            },
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters', style: TextStyle(color: kAccent, fontSize: 13)),
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kAccent))
                : _logs.isEmpty
                    ? const Center(
                        child: Text(
                          "No scans recorded for these filters.",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchScanLogs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            final date = DateTime.parse(log['created_at']).toLocal();
                            final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: kAccent.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.qr_code_scanner_rounded, color: kAccent),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log['employee_name'] ?? 'Unknown Employee',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: kNavy),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "ID: ${log['employee_id']}",
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          log['type']?.toString().toUpperCase() ?? 'LUNCH',
                                          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
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
    );
  }
}
