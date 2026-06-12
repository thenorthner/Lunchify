import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'config.dart';

class AdminScanHistoryPage extends StatefulWidget {
  const AdminScanHistoryPage({Key? key}) : super(key: key);

  @override
  State<AdminScanHistoryPage> createState() => _AdminScanHistoryPageState();
}

class _AdminScanHistoryPageState extends State<AdminScanHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchScanLogs();
  }

  Future<void> _fetchScanLogs() async {
    final token = AuthService.token;
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/qr/scan-logs'),
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

  @override
  Widget build(BuildContext context) {
    const kBg = Color(0xFFF8FAFC);
    const kNavy = Color(0xFF0F172A);
    const kAccent = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text(
          "Current Month Scans",
          style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kNavy),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _logs.isEmpty
              ? const Center(
                  child: Text(
                    "No scans recorded this month.",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final date = DateTime.parse(log['created_at']).toLocal();
                    final formattedDate = "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                    
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
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kNavy),
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
                                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
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
    );
  }
}
