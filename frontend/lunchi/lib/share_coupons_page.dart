import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'config.dart';
import 'auth_service.dart';
import 'widgets/top_bar.dart';
import 'widgets/self_share_dialog.dart';

class ShareCouponsPage extends StatefulWidget {
  const ShareCouponsPage({Key? key}) : super(key: key);

  @override
  State<ShareCouponsPage> createState() => _ShareCouponsPageState();
}

class _ShareCouponsPageState extends State<ShareCouponsPage> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  Future<void> _shareCoupons() async {
    final recipientId = _recipientController.text.trim();
    final amountStr = _amountController.text.trim();

    if (recipientId.isEmpty || amountStr.isEmpty) {
      _showSnackBar("Please fill out both fields.", Colors.red);
      return;
    }

    final myId = AuthService.user?['id']?.toString();
    if (recipientId == myId) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const SelfShareDialog(),
      );
      return;
    }

    final amount = int.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      _showSnackBar("Please enter a valid number of coupons.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userInfo = await AuthService.checkId(recipientId);
      final recipientName = userInfo['name'];

      if (recipientName == null) {
        setState(() => _isLoading = false);
        _showSnackBar(
          userInfo['message'] ?? "Invalid or inactive employee ID.",
          Colors.red,
        );
        return;
      }

      setState(() => _isLoading = false);

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Transfer"),
          content: Text(
            "Really wanna give shiny coupons to $recipientName?",
            style: const TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Maybe Not",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A8F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Bless The Homie ✨",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isLoading = true);
        await _executeShare(recipientId, amount);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

  Future<void> _executeShare(String recipientId, int amount) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.shareCoupons),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'receiverId': recipientId, 'amount': amount}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar(
          data['message'] ?? "Coupons shared successfully!",
          Colors.green,
        );
        _recipientController.clear();
        _amountController.clear();
      } else {
        _showSnackBar(
          data['message'] ?? "Failed to share coupons.",
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar("Network error: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kBgColor = Color(0xFFF8FAFC);
    const Color kPrimaryBlue = Color(0xFF1A3A8F);

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Share Coupons"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 80,
                      color: kPrimaryBlue,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Transfer your extra coupons to a colleague. Make sure the Employee ID is correct.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _recipientController,
                      label: "Recipient Employee ID",
                      icon: Icons.badge,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _amountController,
                      label: "Number of Coupons",
                      icon: Icons.confirmation_number,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A2E6E), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A2E6E).withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _shareCoupons,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Share Coupons",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A3A8F)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A3A8F), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }
}
