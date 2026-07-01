//menu_setup_page.dart
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';

class MenuSetupPage extends StatefulWidget {
  const MenuSetupPage({super.key});

  @override
  State<MenuSetupPage> createState() => _MenuSetupPageState();
}

class _MenuSetupPageState extends State<MenuSetupPage> {
  final List<String> foodOptions = ['Rice', 'Dal', 'Paneer', 'Roti', 'Salad'];
  final List<String> fruitOptions = ['Apple', 'Banana', 'Orange', 'Grapes'];

  String selectedFood = 'Rice';
  String selectedFruit = 'Apple';

  List<String> addedFood = [];
  List<String> addedFruit = [];

  void addFood() {
    if (!addedFood.contains(selectedFood)) {
      setState(() => addedFood.add(selectedFood));
    }
  }

  void addFruit() {
    if (!addedFruit.contains(selectedFruit)) {
      setState(() => addedFruit.add(selectedFruit));
    }
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    final t = raw.trimLeft();
    if (t.startsWith('<!doctype') || t.startsWith('<html') || t.startsWith('<')) return null;
    if (!t.startsWith('{')) return null;
    try {
      final d = jsonDecode(raw);
      return d is Map<String, dynamic> ? d : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveMenu() async {
    final body = {
      'food': addedFood,
      'fruits': addedFruit,
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/menu/setup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Menu saved successfully!")),
        );
      } else {
        final decoded = _tryDecodeMap(response.body);
        final message = decoded?['message']?.toString() ?? 'Failed to save menu.';
        throw Exception(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error saving menu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Today's Menu"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/menu_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.85),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const Text("🍱 Add Food Items",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedFood,
                          decoration: const InputDecoration(
                            labelText: "Select food",
                            border: OutlineInputBorder(),
                          ),
                          items: foodOptions
                              .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                              .toList(),
                          onChanged: (val) => setState(() => selectedFood = val!),
                        ),
                      ),
                      IconButton(
                        onPressed: addFood,
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: addedFood.map((e) => Chip(label: Text(e))).toList(),
                  ),

                  const SizedBox(height: 30),
                  const Text("🍓 Add Fruit Items",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedFruit,
                          decoration: const InputDecoration(
                            labelText: "Select fruit",
                            border: OutlineInputBorder(),
                          ),
                          items: fruitOptions
                              .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                              .toList(),
                          onChanged: (val) => setState(() => selectedFruit = val!),
                        ),
                      ),
                      IconButton(
                        onPressed: addFruit,
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: addedFruit.map((e) => Chip(label: Text(e))).toList(),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: saveMenu,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Menu"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
