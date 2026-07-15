import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'config.dart';
import 'auth_service.dart';

class AdminOrdersPage extends StatefulWidget {
  final int initialIndex;
  const AdminOrdersPage({super.key, this.initialIndex = 0});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> foodOrders = [];
  List<dynamic> fruitOrders = [];
  bool isLoading = true;
  String? error;

  String searchQuery = '';
  DateTime? selectedDate;
  DateTime? selectedMonth;
  int? selectedYear;
  bool _sortNewest = true;

  final Color primaryCoral = const Color(0xFFFF6F4E);
  final Color deepBrown = const Color(0xFF4E342E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final foodRes = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/food-lunch/details"),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      final fruitRes = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/api/fruit-lunch/details"),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (foodRes.statusCode == 200 && fruitRes.statusCode == 200) {
        setState(() {
          foodOrders = json.decode(foodRes.body);
          fruitOrders = json.decode(fruitRes.body);
          isLoading = false;
        });
      } else {
        throw Exception("Server failed: Food ${foodRes.statusCode}, Fruit ${fruitRes.statusCode}");
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _markAsTaken(String type, String orderId) async {
    try {
      final path = type == 'food' ? 'food-lunch-orders' : 'fruit-lunch-orders';
      final res = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/$path/$orderId/mark-delivered'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Lunch successfully marked as Taken!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchOrders();
      } else {
        final body = json.decode(res.body);
        throw Exception(body['error'] ?? 'Failed to update order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<dynamic> _getFilteredOrders(List<dynamic> rawList) {
    var filtered = rawList.where((o) {
      // 1. Search Query filter (Employee ID or Name)
      final name = (o['employee_name'] ?? o['name'] ?? '').toString().toLowerCase();
      final empId = (o['employee_id'] ?? o['employeeId'] ?? '').toString().toLowerCase();
      final matchSearch = name.contains(searchQuery.toLowerCase()) || empId.contains(searchQuery.toLowerCase());

      // 2. Date Filter
      bool matchDate = true;
      final orderDate = (o['date'] ?? '').toString();
      try {
        final date = DateTime.parse(orderDate);
        if (selectedDate != null) {
          matchDate = orderDate.startsWith("${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}");
        } else if (selectedMonth != null) {
          matchDate = date.year == selectedMonth!.year && date.month == selectedMonth!.month;
        } else if (selectedYear != null) {
          matchDate = date.year == selectedYear;
        }
      } catch (_) { }

      // 3. Status Filter (Hide pending and cancelled)
      final status = (o['status'] ?? '').toString().toLowerCase();
      final matchStatus = status != 'pending' && status != 'cancelled';

      return matchSearch && matchDate && matchStatus;
    }).toList();
    
    filtered.sort((a, b) {
      final d1 = a['date'] != null ? DateTime.tryParse(a['date']) : null;
      final d2 = b['date'] != null ? DateTime.tryParse(b['date']) : null;
      if (d1 == null || d2 == null) return 0;
      return _sortNewest ? d2.compareTo(d1) : d1.compareTo(d2);
    });
    
    return filtered;
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.grey.shade200;
    Color fg = Colors.grey.shade700;
    String text = status.toUpperCase();

    if (status == 'pending') {
      bg = const Color(0xFFFFF9C4); // Light yellow
      fg = const Color(0xFFF57F17); // Dark yellow
      text = "Pending Approval";
    } else if (status == 'accepted') {
      bg = const Color(0xFFE3F2FD); // Light blue
      fg = const Color(0xFF0D47A1); // Dark blue
      text = "Ready to Collect";
    } else if (status == 'delivered') {
      bg = const Color(0xFFE8F5E9); // Light green
      fg = const Color(0xFF1B5E20); // Dark green
      text = "Lunch Taken";
    } else if (status == 'rejected' || status == 'cancelled') {
      bg = const Color(0xFFFFEBEE); // Light red
      fg = const Color(0xFFB71C1C); // Dark red
      text = "Cancelled";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic o, String type) {
    final id = o['id'].toString();
    final name = o['employee_name'] ?? 'Unknown Employee';
    final empId = o['employee_id'] ?? o['employeeId'] ?? 'N/A';
    final itemName = o['item_name'] ?? o['name'] ?? (type == 'food' ? 'Food Lunch' : 'Fruit Lunch');
    final qty = o['quantity']?.toString() ?? '1';
    final status = o['status'] ?? 'pending';
    
    String date = o['date'] ?? 'N/A';
    try {
      if (date != 'N/A') {
        final parsedDate = DateTime.parse(date).toLocal();
        date = DateFormat('MMM dd, yyyy').format(parsedDate);
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A8F).withOpacity(0.06), // kPrimaryBlue
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Name & Qty
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF0F5FB), // kSubtle
                        child: Icon(
                          type == 'food' ? Icons.restaurant : Icons.eco,
                          color: const Color(0xFF1A3A8F), // kPrimaryBlue
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Color(0xFF1A2E6E), // kNavy
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                              Text(
                                "Emp ID: $empId • Item: $itemName",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A96A8), // kGray
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Qty: $qty",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A8F),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFDCE8F5)), // kBorder

            // Show Items if available
            if (o['items'] != null) ...[
              const Text("Selected Items:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2E6E))),
              const SizedBox(height: 8),
              ..._buildItemsList(o['items']),
              const Divider(height: 24, color: Color(0xFFDCE8F5)),
            ],

            // Details list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Order Date: $date",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8A96A8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(status),
              ],
            ),

            // Actions row
            if (status == 'accepted' && type == 'food') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markAsTaken(type, id),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  label: const Text(
                    "Mark Lunch Taken",
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1A3A8F), // kPrimaryBlue
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemsList(dynamic itemsData) {
    List<dynamic> items = [];
    if (itemsData is String) {
      try {
        items = json.decode(itemsData);
      } catch (e) {
        return [Text(itemsData.toString())];
      }
    } else if (itemsData is List) {
      items = itemsData;
    }

    return items.map((item) {
      final name = item['name'] ?? 'Unknown Item';
      final q = item['quantity']?.toString() ?? '1';
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            const Icon(Icons.arrow_right, size: 16, color: Color(0xFF8A96A8)),
            const SizedBox(width: 4),
            Text(
              "${q}x $name",
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A2340)),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildOrdersList(List<dynamic> list, String type) {
    final filtered = _getFilteredOrders(list);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFFDCE8F5)),
            const SizedBox(height: 12),
            const Text(
              "No matching orders found.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8A96A8), // kGray
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildOrderCard(filtered[i], type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FB), // kSubtle
            body: Column(
          children: [
            _TopBar(title: 'Lunch Collection Tracker', onRefresh: _fetchOrders),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1A3A8F),
                unselectedLabelColor: const Color(0xFF8A96A8),
                indicatorColor: const Color(0xFF1A3A8F),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.restaurant, size: 20), text: "Food Lunch"),
                  Tab(icon: Icon(Icons.eco, size: 20), text: "Fruit Lunch"),
                ],
              ),
            ),
          // Search & Date Filter Panel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A3A8F).withOpacity(0.06), // kPrimaryBlue
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search name or ID...",
                        hintStyle: TextStyle(color: Color(0xFF8A96A8)), // kGray
                        prefixIcon: Icon(Icons.search, color: Color(0xFF5A7CC9)), // kSubtext
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Calendar Button
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF1A3A8F), // kPrimaryBlue
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF1A2E6E), // kNavy
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1A3A8F),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selectedDate != null ? const Color(0xFF1A3A8F) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A3A8F).withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: selectedDate != null ? Colors.white : const Color(0xFF1A3A8F),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filter Chips
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text(
                    "Date: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A3A8F)),
                  ),
                  onDeleted: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                  deleteIconColor: const Color(0xFF1A3A8F),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFDCE8F5)),
                ),
              ),
            ),
            
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _sortNewest ? 'newest' : 'oldest',
                    items: const [
                      DropdownMenuItem(value: 'newest', child: Text('Sort: Newest')),
                      DropdownMenuItem(value: 'oldest', child: Text('Sort: Oldest')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _sortNewest = v == 'newest');
                    },
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<int?>(
                    value: selectedYear,
                    hint: const Text('Year'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Years')),
                      ...List.generate(5, (i) => DateTime.now().year - i)
                          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))),
                    ],
                    onChanged: (v) => setState(() => selectedYear = v),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<int?>(
                    value: selectedMonth?.month,
                    hint: const Text('Month'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Months')),
                      ...List.generate(12, (i) => i + 1)
                          .map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0')))),
                    ],
                    onChanged: (v) {
                       setState(() {
                         if (v == null) selectedMonth = null;
                         else selectedMonth = DateTime(DateTime.now().year, v);
                       });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Tab Views
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3A8F)))
                : error != null
                    ? Center(
                        child: Text(
                          "❌ Error loading orders: $error",
                          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrdersList(foodOrders, 'food'),
                          _buildOrdersList(fruitOrders, 'fruit'),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}


// --- Top Bar ------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  const _TopBar({required this.title, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130, // Increased height to accommodate SafeArea on modern phones
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color(0xFFD0DCF0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sjvn_scene.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD0DCF0), Color(0xFFBFD3EA)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.45, 0.72, 1.0],
                  colors: [
                    Color(0xFFEAF2FF),
                    Color(0xD0EAF2FF),
                    Color(0x88EAF2FF),
                    Color(0x10EAF2FF),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                _BackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2E6E),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF1A2E6E)),
                    onPressed: onRefresh,
                    tooltip: "Refresh list",
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

// --- Animated Back Button -----------------------------------------------------
class _BackButton extends StatefulWidget {
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<double>(begin: 0, end: -4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit:  (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(_slide.value, 0.0)
              ..scale(_scale.value),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2E6E).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF1A2E6E), size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

