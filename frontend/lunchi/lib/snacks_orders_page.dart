import 'dart:convert';
import 'config.dart';

import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SnackOrderPage extends StatefulWidget {
  const SnackOrderPage({super.key});

  @override
  State<SnackOrderPage> createState() => _SnackOrderPageState();
}

class _SnackOrderPageState extends State<SnackOrderPage> {
  final String baseUrl = AppConfig.apiBaseUrl;

  List snacks = [];
  Map<int, int> quantities = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSnacks();
  }

  // 🔹 Fetch snacks menu
  Future<void> fetchSnacks() async {
    final res = await http.get(Uri.parse('$baseUrl/api/snacks/menu'));

    if (res.statusCode == 200) {
      snacks = json.decode(res.body);
      setState(() => loading = false);
    } else {
      throw Exception('Failed to load snacks');
    }
  }

  // 🔹 Calculate total price
  int get totalAmount {
    int total = 0;
    for (var snack in snacks) {
      final qty = quantities[snack['id']] ?? 0;
      total += qty * snack['price'] as int;
    }
    return total;
  }

  // 🔹 Place order & redirect to payment
  Future<void> placeOrder() async {
    final orderedItems = snacks
        .where((s) => (quantities[s['id']] ?? 0) > 0)
        .map((s) {
      final qty = quantities[s['id']]!;
      return {
        "name": s['name'],
        "quantity": qty,
        "price": s['price'],
        "subtotal": qty * s['price']
      };
    }).toList();

    if (orderedItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select items')));
      return;
    }

    final payload = {
      "employee_id": "EMP001",
      "name": "Urvi",
      "room": "301",
      "items": orderedItems,
      "total": totalAmount
    };

    final res = await http.post(
      Uri.parse('$baseUrl/api/snacks/order'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    if (res.statusCode == 200) {
      openPayment();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order failed')));
    }
  }

  // 🔹 Open UPI payment app
  void openPayment() async {
    final upiUrl =
        'upi://pay?pa=merchant@upi&pn=Snack%20Canteen&am=$totalAmount&cu=INR';

    if (await canLaunchUrl(Uri.parse(upiUrl))) {
      await launchUrl(Uri.parse(upiUrl),
          mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No UPI app found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Snacks')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: snacks.length,
              itemBuilder: (context, index) {
                final snack = snacks[index];
                final qty = quantities[snack['id']] ?? 0;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(snack['name']),
                    subtitle: Text('₹${snack['price']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: qty > 0
                              ? () => setState(() =>
                          quantities[snack['id']] = qty - 1)
                              : null,
                        ),
                        Text(qty.toString(),
                            style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() =>
                          quantities[snack['id']] = qty + 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 Total + Order button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border:
              Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹$totalAmount',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: placeOrder,
                  child: const Text('Pay & Order'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
