import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';


import 'config.dart';
import 'auth_service.dart';
import 'widgets/top_bar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  int _rating = 5;
  bool _isLoading = false;

  static const accentOrange = Color(0xFFFF715B);
  static const darkGray = Color(0xFF222222);
  static const warmBackground = Color(0xFFFFF7ED);

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse(AppConfig.feedbacks),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
          'rating': _rating,
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 201 || (body is Map && body['success'] == true)) {
        _showToast(body['message'] ?? 'Feedback submitted successfully! Thank you.', isSuccess: true);
        if (mounted) Navigator.pop(context);
      } else {
        final errorMsg = body['error'] ?? body['message'] ?? 'Failed to submit feedback';
        _showToast(errorMsg, isSuccess: false);
      }
    } catch (e) {
      _showToast('Cannot connect to the server: $e', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FB), // kSubtle
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Report a Bug"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A3A8F).withOpacity(0.06), // kPrimaryBlue
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "Found a bug or something not working? Report it below and the IT admin team will look into it.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A96A8), // kGray
                                ),
                              ),
                              const SizedBox(height: 24),
                                // SUBJECT FIELD
                              const Text(
                                "Subject / Topic",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2340), // kDarkText
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _subjectController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter a subject";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "e.g., QR scan not working, Order not showing, App crash",
                                  hintStyle: const TextStyle(color: Color(0xFF8A96A8)), // kGray
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFDCE8F5)), // kBorder
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFDCE8F5)), // kBorder
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF1A3A8F), width: 2), // kPrimaryBlue
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F5FB), // kSubtle
                                ),
                              ),
                              const SizedBox(height: 24),
  
                              // DETAILED MESSAGE
                              const Text(
                                "Details / Description",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2340), // kDarkText
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _messageController,
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please describe the bug or issue";
                                  }
                                  if (value.trim().length < 10) {
                                    return "Please describe in at least 10 characters";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Describe the bug step by step so we can fix it...",
                                  hintStyle: const TextStyle(color: Color(0xFF8A96A8)), // kGray
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFDCE8F5)), // kBorder
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFDCE8F5)), // kBorder
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF1A3A8F), width: 2), // kPrimaryBlue
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F5FB), // kSubtle
                                ),
                              ),
                              const SizedBox(height: 32),
  
                              // SUBMIT BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A3A8F), // kPrimaryBlue
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading ? null : _submitFeedback,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Submit Ticket",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
