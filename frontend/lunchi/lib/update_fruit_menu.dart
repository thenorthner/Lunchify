//update_fruit_menu.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class UpdateFruitMenu extends StatefulWidget {
  const UpdateFruitMenu({super.key});

  @override
  State<UpdateFruitMenu> createState() => _UpdateFruitMenuState();
}

class _UpdateFruitMenuState extends State<UpdateFruitMenu> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = true;

  Map<String, dynamic> _decodeMapOrThrow(http.Response res, {String? hint}) {
    final raw = res.body;
    final trimmed = raw.trimLeft();
    final preview = raw.substring(0, raw.length > 350 ? 350 : raw.length);

    if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<html') || trimmed.startsWith('<')) {
      throw Exception('${hint ?? "API"} returned HTML (not JSON). HTTP ${res.statusCode}. Preview: $preview');
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('${hint ?? "API"} Expected JSON object but got ${decoded.runtimeType}');
  }

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

  Future<void> loadExistingMenu() async {
    final today = getTodayDate();
    final url = "${AppConfig.apiBaseUrl}/api/menu/fruit?date=$today";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = _decodeMapOrThrow(response, hint: 'Fruit menu get');
        final List<String> fruits = List<String>.from(data['items'] ?? []);
        controller.text = fruits.join(', ');
      }
    } catch (e) {
      debugPrint("Error loading fruit menu: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveMenu() async {
    final fruits = controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (fruits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one fruit")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/api/menu/fruit"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          "menu_date": getTodayDate(),
          "fruits": fruits
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Fruit menu saved")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Server error (HTTP ${response.statusCode})");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Fruit Menu")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's fruits (comma separated)",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Apple, Banana, Orange",
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
