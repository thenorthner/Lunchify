import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class FruitLunchOrdersPage extends StatefulWidget {
  const FruitLunchOrdersPage({super.key});

  @override
  State<FruitLunchOrdersPage> createState() =>
      _FruitLunchOrdersPageState();
}

class _FruitLunchOrdersPageState
    extends State<FruitLunchOrdersPage> {
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
      final uri = Uri.parse(AppConfig.fruitLunchOrdersDetails);
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      debugPrint('📡 GET $uri');
      debugPrint('📦 STATUS ${res.statusCode}');
      debugPrint('📦 CONTENT-TYPE ${res.headers['content-type']}');
      debugPrint('📦 BODY ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Server error ${res.statusCode}');
      }

      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        throw Exception('Server returned non-JSON response');
      }

      final decoded = json.decode(res.body);

      if (decoded is List) {
        orders = decoded;
      } else if (decoded is Map && decoded['orders'] is List) {
        orders = decoded['orders'];
      } else {
        orders = [];
      }
    } catch (e) {
      error = e.toString();
      orders = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTile(dynamic o) {
    final empId = o['employeeId'] ?? o['employee_id'] ?? 'N/A';
    final orderType = o['orderType'] ?? o['order_type'] ?? 'N/A';
    final room = o['room'] ?? o['room_number'] ?? '-';
    final deliveryTime =
        o['deliveryTime'] ?? o['delivery_time'] ?? '-';
    final date = o['date'] ?? '';
    final created = o['createdAt'] ?? o['created_at'] ?? '';

    final List items = o['items'] is List
        ? o['items']
        : [
      {
        'name': o['name'] ?? 'Fruit Lunch',
        'quantity': o['quantity'] ?? 1,
      }
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee ID: $empId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            ...items.map(
                  (i) => Text('• ${i['name']} × ${i['quantity']}'),
            ),

            const SizedBox(height: 6),
            Text(
              'Type: ${orderType == 'cabin'
                  ? 'Order in Cabin'
                  : orderType == 'dineIn'
                  ? 'Dine In'
                  : orderType}',
            ),

            if (orderType == 'cabin')
              Text('Room: $room  • Delivery: $deliveryTime'),

            if (date.toString().isNotEmpty)
              Text('Date: $date'),

            if (created.toString().isNotEmpty)
              Text('Placed: $created'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit Lunch — Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDetails,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Text(
          error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
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
