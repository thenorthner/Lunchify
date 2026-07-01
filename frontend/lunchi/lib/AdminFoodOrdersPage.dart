//AdminFoodOrdersPage.dart
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'package:lunchi/config.dart';
import 'package:lunchi/auth_service.dart';

class AdminFoodOrdersPage extends StatefulWidget {
  const AdminFoodOrdersPage({super.key});

  @override
  State<AdminFoodOrdersPage> createState() => _AdminFoodOrdersPageState();
}

class _AdminFoodOrdersPageState extends State<AdminFoodOrdersPage> {
  List<dynamic> requests = [];
  bool isLoading = false;

  List<dynamic> _decodeListOrThrow(http.Response res, {String? hint}) {
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    final raw = res.body;
    final trimmed = raw.trimLeft();
    final preview = raw.substring(0, raw.length > 350 ? 350 : raw.length);

    if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<html') || trimmed.startsWith('<')) {
      throw Exception('${hint ?? "API"} returned HTML (not JSON). HTTP ${res.statusCode}. Preview: $preview');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('${hint ?? "API"} HTTP ${res.statusCode}. Preview: $preview');
    }
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded;
    throw Exception('${hint ?? "API"} Expected JSON List but got ${decoded.runtimeType}');
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/food-lunch-orders/room-requests');
      final res = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      final list = _decodeListOrThrow(res, hint: 'Food room requests');
      setState(() => requests = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to load: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _approve(String requestId) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/food-lunch-orders/approve-room-order');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'requestId': requestId}),
      );

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Request approved')),
          );
        }
        _loadRequests();
      } else {
        throw Exception('Approve failed (HTTP ${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Approve failed: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Food Room Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (_, index) {
          final req = requests[index];
          return ListTile(
            title: Text('${req['employeeId']} - ${req['quantity']} lunch(es)'),
            subtitle: Text('Requested at: ${req['requestedAt']}'),
            trailing: ElevatedButton(
              child: const Text('Approve'),
              onPressed: () => _approve(req['_id'].toString()),
            ),
          );
        },
      ),
    );
  }
}
