import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'auth_service.dart';

class FoodLunchOrdersPage extends StatefulWidget {
  const FoodLunchOrdersPage({super.key});

  @override
  State<FoodLunchOrdersPage> createState() => _FoodLunchOrdersPageState();
}

class _FoodLunchOrdersPageState extends State<FoodLunchOrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final res = await http.get(
        Uri.parse(AppConfig.foodLunchOrdersDetails),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );
      if (res.statusCode == 200) {
        orders = json.decode(res.body);
      } else {
        error = 'Server error: ${res.statusCode}';
      }
    } catch (e) {
      error = 'Network/error: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTile(dynamic o) {
    final name = o['name'] ?? 'Unknown';
    final empId = o['employee_id'] ?? 'N/A';
    final qty = o['quantity']?.toString() ?? '1';
    final orderType = o['order_type'] ?? 'N/A';
    final room = o['room_number'] ?? '-';
    final deliveryTime = o['delivery_time'] ?? '-';
    final date = o['date'] ?? '';
    final created = o['created_at'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.restaurant, color: Colors.teal),
        title: Text('$name • $empId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
                'Qty: $qty • Type: ${orderType == 'cabin' ? 'Order in Cabin' : (orderType == 'dineIn' ? 'Dine In' : orderType)}'),
            if (orderType == 'cabin')
              Text('Room: $room  • Delivery: $deliveryTime'),
            if (date.toString().isNotEmpty) Text('Date: $date'),
            if (created.toString().isNotEmpty) Text('Placed: $created'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Lunch — Orders (Details)'),
        actions: [
          IconButton(onPressed: _fetchDetails, icon: const Icon(Icons.refresh))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)))
          : orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : RefreshIndicator(
        onRefresh: _fetchDetails,
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (_, i) => _buildTile(orders[i]),
        ),
      ),
    );
  }
}
