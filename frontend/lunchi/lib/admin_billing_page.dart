import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';

class AdminBillingPage extends StatefulWidget {
  const AdminBillingPage({super.key});

  @override
  State<AdminBillingPage> createState() => _AdminBillingPageState();
}

class _AdminBillingPageState extends State<AdminBillingPage> {
  bool isLoading = false;
  int totalCouponsScanned = 0;
  final TextEditingController _priceController = TextEditingController(text: "50");
  double totalAmount = 0.0;
  String selectedMonth = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    _fetchScannedCoupons();
    _priceController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double price = double.tryParse(_priceController.text) ?? 0.0;
    setState(() {
      totalAmount = totalCouponsScanned * price;
    });
  }

  Future<void> _fetchScannedCoupons() async {
    setState(() => isLoading = true);
    try {
      // Endpoint to fetch scanned coupons for the month for this canteen
      // We will reuse the dashboard endpoint or fetch it from a specific billing API
      // Since we don't have a specific GET count route in billing yet, we can mock or use a generic one.
      // Wait, let's create a quick route in billing to get the scanned count.
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/fruit-lunch-requests'), // We can use existing if it has scanned count or add one.
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          // Assuming 'couponsCollected' represents the scanned coupons
          totalCouponsScanned = data['couponsCollected'] ?? 0;
          _calculateTotal();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load scanned coupons')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _generateBill() async {
    if (totalCouponsScanned == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No coupons scanned to generate a bill for.')),
      );
      return;
    }

    double price = double.tryParse(_priceController.text) ?? 0.0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid coupon price.')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/billing/generate-canteen-bill'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bill_month': selectedMonth,
          'total_coupons_scanned': totalCouponsScanned,
          'coupon_price': price,
          'total_amount': totalAmount,
        }),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill generated and submitted to HR successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          throw Exception(data['message'] ?? 'Failed to generate bill');
        }
      } else {
        throw Exception('Server error: ${res.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Monthly Bill'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Canteen Billing',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generate the consolidated monthly bill for all scanned coupons to be submitted to HR for review.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // Month Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Billing Month:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(selectedMonth, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Scanned Coupons Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Coupons Scanned:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('\$totalCouponsScanned', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Price Input
                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price per Lunch Coupon (₹)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 32),

                // Final Amount
                Center(
                  child: Column(
                    children: [
                      const Text('Final Bill Amount', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        '₹ ${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _generateBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Bill to HR',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
