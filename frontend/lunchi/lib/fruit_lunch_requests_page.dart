import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';

class FruitLunchRequestsPage extends StatefulWidget {
  const FruitLunchRequestsPage({super.key});

  @override
  State<FruitLunchRequestsPage> createState() => _FruitLunchRequestsPageState();
}

class _FruitLunchRequestsPageState extends State<FruitLunchRequestsPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/fruit-lunch-orders'), // ✅ updated endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _requests = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = "❌ Failed to load requests: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fruit Lunch Requests"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fruit_lunch_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : _error != null
                ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
                : _requests.isEmpty
                ? const Center(
              child: Text(
                "No fruit lunch requests yet.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                final name = request['name'] ?? 'Unknown';
                final empId = request['employee_id'] ?? 'N/A'; // ✅ match backend
                final room = request['room_number'] ?? 'N/A'; // ✅ match backend
                final time = request['delivery_time'] ?? 'N/A'; // ✅ new field
                final qty = request['quantity']?.toString() ?? '1'; // ✅ optional

                return Card(
                  color: Colors.white.withOpacity(0.9),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: Text("$name ($empId)"),
                    subtitle: Text("Room: $room | Time: $time | Qty: $qty"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
