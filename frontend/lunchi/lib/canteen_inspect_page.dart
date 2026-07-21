import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';

class CanteenInspectPage extends StatefulWidget {
  final String canteenId;
  final String canteenName;
  final String location;

  const CanteenInspectPage({
    Key? key,
    required this.canteenId,
    required this.canteenName,
    required this.location,
  }) : super(key: key);

  @override
  State<CanteenInspectPage> createState() => _CanteenInspectPageState();
}

class _CanteenInspectPageState extends State<CanteenInspectPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  Map<String, dynamic> menuData = {};
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_filterUsers);
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/canteens/${widget.canteenId}/details'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          users = data['users'] ?? [];
          filteredUsers = users;
          menuData = data['menu'] ?? {};
          isLoading = false;
        });
      } else {
        _showError('Failed to fetch details');
      }
    } catch (e) {
      _showError('Network error: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final empId = (u['emp_id'] ?? '').toString().toLowerCase();
        return name.contains(query) || empId.contains(query);
      }).toList();
    });
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A), // Dark navy theme
        title: Text(widget.canteenName, style: const TextStyle( fontSize: 18, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6), // Blue indicator
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(text: "Employees & Admins"),
            Tab(text: "Today's Menu"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildMenuTab(),
              ],
            ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by Name or Emp ID...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        // User List
        Expanded(
          child: filteredUsers.isEmpty
              ? const Center(child: Text("No users found", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final u = filteredUsers[index];
                    final role = u['role'] ?? 'user';
                    final isCanteenAdmin = role == 'canteen_admin';
                    final isHR = role == 'hr_admin';
                    final isIT = role == 'it_admin';
                    
                    Color roleColor = Colors.grey;
                    String roleText = "Employee";
                    if (isCanteenAdmin) { roleColor = Colors.orange; roleText = "Canteen Admin"; }
                    if (isHR) { roleColor = Colors.purple; roleText = "HR Admin"; }
                    if (isIT) { roleColor = Colors.red; roleText = "IT Admin"; }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleColor.withOpacity(0.1),
                          child: Icon(Icons.person, color: roleColor),
                        ),
                        title: Text(u['name'] ?? 'Unknown', style: const TextStyle( fontSize: 15)),
                        subtitle: Text("ID: ${u['emp_id']} • ${u['department'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        trailing: role != 'user' 
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(roleText, style: TextStyle(color: roleColor, fontSize: 11, )),
                            )
                          : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMenuTab() {
    final food = menuData['food'];
    final fruit = menuData['fruit'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMenuCard("Lunch Menu", food ?? "Not set for today", Icons.restaurant, Colors.orange),
        const SizedBox(height: 16),
        _buildMenuCard("Fruit Menu", fruit ?? "Not set for today", Icons.apple, Colors.red),
      ],
    );
  }

  Widget _buildMenuCard(String title, String items, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18,  color: Color(0xFF1E293B))),
            ],
          ),
          const Divider(height: 32),
          Text(
            items,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
          ),
        ],
      ),
    );
  }
}
