//update_food_menu.dart

import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'auth_service.dart';

class UpdateFoodMenu extends StatefulWidget {
  const UpdateFoodMenu({super.key});

  @override
  State<UpdateFoodMenu> createState() => _UpdateFoodMenuState();
}

class _UpdateFoodMenuState extends State<UpdateFoodMenu> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExistingMenu();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  bool _looksLikeHtml(String body) {
    final t = body.trimLeft().toLowerCase();
    return t.startsWith('<!doctype') || t.startsWith('<html') || t.startsWith('<');
  }

  Map<String, dynamic>? _tryDecodeMap(String body) {
    if (_looksLikeHtml(body)) return null;
    final t = body.trimLeft();
    if (!t.startsWith('{')) return null;
    try {
      final d = jsonDecode(body);
      return d is Map<String, dynamic> ? d : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadExistingMenu() async {
    final today = getTodayDate();
    final url = "${AppConfig.apiBaseUrl}/api/menu/food?date=$today";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = _tryDecodeMap(response.body);
        final List<String> items = List<String>.from(data?['items'] ?? []);
        controller.text = items.join(', ');
      } else {
        debugPrint("Food menu load HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error loading food menu: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveMenu() async {
    final items = controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one item")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/menu/food"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          "menu_date": getTodayDate(),
          "items": items
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Food menu saved")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Server error (HTTP ${response.statusCode})");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Food Menu")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's food items (comma separated)",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Rice, Dal, Sabzi",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveMenu,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
