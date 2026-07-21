import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';
import 'canteen_inspect_page.dart';

class ManageCanteensPage extends StatefulWidget {
  const ManageCanteensPage({Key? key}) : super(key: key);

  @override
  State<ManageCanteensPage> createState() => _ManageCanteensPageState();
}

class _ManageCanteensPageState extends State<ManageCanteensPage> {
  bool isLoading = true;
  List<dynamic> canteens = [];

  @override
  void initState() {
    super.initState();
    _fetchCanteens();
  }

  Future<void> _fetchCanteens() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/canteens'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      if (res.statusCode == 200) {
        setState(() {
          canteens = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        _showError("Failed to fetch canteens");
      }
    } catch (e) {
      _showError("Network error: $e");
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteCanteen(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Canteen"),
        content: Text("Are you sure you want to delete '$name'? All users will be moved to CHQ."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete")
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      final res = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/api/canteens/$id'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      if (res.statusCode == 200) {
        _fetchCanteens();
      } else {
        final d = jsonDecode(res.body);
        _showError(d['message'] ?? "Failed to delete");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB), // Light bluish grey
      appBar: AppBar(
        title: const Text("Manage Modules", style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: canteens.length,
              itemBuilder: (context, index) {
                final c = canteens[index];
                return _buildCanteenCard(c);
              },
            ),
    );
  }

  Widget _buildCanteenCard(dynamic canteen) {
    final String cId = canteen['id'].toString();
    final String cName = canteen['name'] ?? 'Unknown Canteen';
    final String cLoc = canteen['location'] ?? 'Unknown Location';
    final int userCount = canteen['user_count'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Dark Navy Gradient)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("PROJECT - $cId", style: const TextStyle(color: Colors.white70, fontSize: 10,  letterSpacing: 1)),
                ),
                const SizedBox(height: 12),
                Text(cName, style: const TextStyle(color: Colors.white, fontSize: 18, )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(cLoc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          
          // Body Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("PROJECT DB ID", style: TextStyle(color: Colors.grey, fontSize: 10,  letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text("#$cId", style: const TextStyle(fontSize: 22, )),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteCanteen(cId, cName),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                        backgroundColor: Colors.red.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Associated Canteen Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ASSOCIATED CANTEEN", style: TextStyle(color: Colors.blue, fontSize: 10,  letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text("$cName Canteen", style: const TextStyle( fontSize: 14)),
                      const SizedBox(height: 16),
                      _infoRow("MODULE ID", "#$cId"),
                      _infoRow("LOCATION", cLoc),
                      _infoRow("EMPLOYEES", "$userCount Active"),
                      _infoRow("STATUS", "• ACTIVE", valueColor: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1),
          
          // Inspect Module Button
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CanteenInspectPage(
                    canteenId: cId,
                    canteenName: cName,
                    location: cLoc,
                  ),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Inspect module", style: TextStyle( color: Color(0xFF1E293B), fontSize: 14)),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color valueColor = const Color(0xFF1E293B)}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, )),
          Text(value, style: TextStyle(color: valueColor, fontSize: 13, )),
        ],
      ),
    );
  }
}
