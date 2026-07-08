import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import '../config.dart';
import 'auth_service.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kNavy    = Color(0xFF1A2E6E);
const _kAccent  = Color(0xFF2563EB);
const _kBg      = Color(0xFFEAF2FF);
const _kCard    = Color(0xFFFFFFFF);
const _kLight   = Color(0xFFDBE9FF);
const _kSubtext = Color(0xFF5A7CC9);
const _kDivider = Color(0xFFE8F0FB);
const _kGreen   = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFDCFCE7);
const _kRed     = Color(0xFFE02020);
const _kRedBg   = Color(0xFFFFEEEE);

// ─── Snack Order Item ─────────────────────────────────────────────────────────
class SnackItem {
  final String name;
  final int qty;
  final int price;

  const SnackItem({
    required this.name,
    required this.qty,
    required this.price,
  });

  int get total => qty * price;
}

// ─── Snack Order Status ───────────────────────────────────────────────────────
enum SnackStatus { delivered, accepted, pending, declined }

// ─── Snack Order Model ────────────────────────────────────────────────────────
class SnackOrder {
  final String id;
  final String employeeName;
  final String employeeId;
  final String pickupType;
  final List<SnackItem> items;
  final SnackStatus status;
  final DateTime? createdAt;

  const SnackOrder({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.pickupType,
    required this.items,
    required this.status,
    this.createdAt,
  });

  int get grandTotal => items.fold(0, (sum, i) => sum + i.total);
}

// ════════════════════════════════════════════════════════════════════════════
//  MANAGE SNACK REQUESTS PAGE
// ════════════════════════════════════════════════════════════════════════════
class SnackRequestsPage extends StatefulWidget {
  const SnackRequestsPage({super.key});

  @override
  State<SnackRequestsPage> createState() => _SnackRequestsPageState();
}

class _SnackRequestsPageState extends State<SnackRequestsPage> {
  bool _isLoading = false;
  List<SnackOrder> _orders = [];
  String? _error;

  DateTime? selectedMonth;
  int? selectedYear;
  bool _sortNewest = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  SnackStatus _parseStatus(String s) {
    if (s.toLowerCase() == 'accepted') return SnackStatus.accepted;
    if (s.toLowerCase() == 'delivered') return SnackStatus.delivered;
    if (s.toLowerCase() == 'declined') return SnackStatus.declined;
    return SnackStatus.pending;
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await http.get(
        Uri.parse(AppConfig.snackOrders),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Map<String, dynamic>> rawRequests = [];
        
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          rawRequests = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          rawRequests = List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Invalid response format');
        }

        final parsedOrders = rawRequests.map((req) {
          final id = req['id'].toString();
          final employeeId = req['employee_id'] ?? req['employeeId'] ?? 'N/A';
          final employeeName = req['name'] ?? 'Unknown';
          final room = req['room'] ?? 'N/A';
          final statusStr = req['status'] ?? 'pending';

          List<SnackItem> parsedItems = [];
          if (req['items'] != null) {
            List<dynamic> itemsList = [];
            if (req['items'] is String) {
              try {
                itemsList = jsonDecode(req['items']);
              } catch (e) {
                debugPrint("Error parsing items string: $e");
              }
            } else if (req['items'] is List) {
              itemsList = req['items'];
            }
            for (var i in itemsList) {
              if (i is Map) {
                parsedItems.add(SnackItem(
                  name: i['snack']?.toString() ?? 'Item',
                  qty: int.tryParse(i['quantity']?.toString() ?? '1') ?? 1,
                  price: int.tryParse(i['cost']?.toString() ?? '0') ?? 0,
                ));
              }
            }
          }

          final createdAtStr = req['created_at'];
          DateTime? createdAtDate;
          if (createdAtStr != null) {
            createdAtDate = DateTime.tryParse(createdAtStr);
          }

          return SnackOrder(
            id: id,
            employeeName: employeeName,
            employeeId: employeeId,
            pickupType: room,
            items: parsedItems,
            status: _parseStatus(statusStr),
            createdAt: createdAtDate,
          );
        }).toList();

        setState(() {
          _orders = parsedOrders;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed with status code ${res.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = '❌ Failed to load snack requests: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      setState(() => _isLoading = true);
      final res = await http.put(
        Uri.parse('${AppConfig.snackOrders}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'status': newStatus}),
      );
      if (res.statusCode == 200) {
        await _fetchRequests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Status updated to $newStatus"),
              backgroundColor: _kGreen,
            ),
          );
        }
      } else {
        throw Exception('Failed to update');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $e"), backgroundColor: _kRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRequest(String id) async {
    try {
      setState(() => _isLoading = true);
      final res = await http.delete(
        Uri.parse('${AppConfig.snackOrders}/$id'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );
      if (res.statusCode == 200) {
        await _fetchRequests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🗑️ Request deleted"),
              backgroundColor: _kNavy,
            ),
          );
        }
      } else {
        throw Exception('Delete failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $e"), backgroundColor: _kRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<SnackOrder> get _filteredOrders {
    var filtered = _orders.where((o) {
      bool matchDate = true;
      if (o.createdAt != null) {
        final date = o.createdAt!;
        if (selectedMonth != null) {
          matchDate = date.year == selectedMonth!.year && date.month == selectedMonth!.month;
        } else if (selectedYear != null) {
          matchDate = date.year == selectedYear;
        }
      }
      return matchDate;
    }).toList();
    
    filtered.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return _sortNewest ? b.createdAt!.compareTo(a.createdAt!) : a.createdAt!.compareTo(b.createdAt!);
    });
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────────────
            _TopBar(),

            // ── Filters ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Expanded(
                    child: DropdownButton<int?>(
                      isExpanded: true,
                      value: selectedYear,
                      hint: const Text('Year'),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('Years')),
                        ...List.generate(5, (i) => DateTime.now().year - i)
                            .map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))),
                      ],
                      onChanged: (v) => setState(() => selectedYear = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<int?>(
                      isExpanded: true,
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
                  ),
                ],
              ),
            ),

            // ── Orders List ───────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kAccent))
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: _kRed, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : filteredOrders.isEmpty
                          ? const _EmptyState()
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                              itemCount: filteredOrders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) => _OrderCard(
                                order: filteredOrders[index],
                                onAccept: null,
                                onDecline: null,
                                onDelete: filteredOrders[index].status == SnackStatus.declined
                                    ? () => _deleteRequest(filteredOrders[index].id)
                                    : null,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
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
          // Background image
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
          // Gradient overlay
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
          // Back button + Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 38),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BackButton(),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Manage Snack Requests',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _kNavy,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Back Button ─────────────────────────────────────────────────────
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
    _slide = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
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
                    color: _kNavy.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: _kNavy, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final SnackOrder order;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onDelete;

  const _OrderCard({required this.order, this.onAccept, this.onDecline, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isAccepted  = order.status == SnackStatus.accepted;
    final isDelivered = order.status == SnackStatus.delivered;
    final isDeclined  = order.status == SnackStatus.declined;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header row: avatar + name + pickup type ───────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _kLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: _kAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),

              // Name + ID
              Expanded(
                child: Text(
                  '${order.employeeName} (${order.employeeId})',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
                  ),
                ),
              ),

              // Dot separator
              const Text(
                ' • ',
                style: TextStyle(color: _kSubtext, fontSize: 16),
              ),

              // Pickup type
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: _kAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.pickupType,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Items list ────────────────────────────────────────────────
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                '${item.name} × ${item.qty} = ₹${item.total}',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF334155),
                  height: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 12),

          // ── Total & Date ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:  ₹${order.grandTotal}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _kNavy,
                ),
              ),
              if (order.createdAt != null)
                Text(
                  '${order.createdAt!.year}-${order.createdAt!.month.toString().padLeft(2, '0')}-${order.createdAt!.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kSubtext,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Status row ────────────────────────────────────────────────
          Row(
            children: [
              // Status badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isAccepted ? _kGreenBg : isDeclined ? _kRedBg : _kLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDelivered
                          ? Icons.local_shipping_rounded
                          : isAccepted
                              ? Icons.check_circle_rounded
                              : isDeclined
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_top_rounded,
                      color: isAccepted ? _kGreen : isDeclined ? _kRed : _kAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${order.status.name}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isAccepted ? _kGreen : isDeclined ? _kRed : _kAccent,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Accept/Decline button — shown only for pending orders

              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _kRedBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: _kRed, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: _kRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Green tick — shown for accepted orders
              if (isAccepted)
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: _kGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFDBE9FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF2563EB),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Snack Requests Yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2E6E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'All snack orders will appear here.',
            style: TextStyle(fontSize: 13, color: Color(0xFF5A7CC9)),
          ),
        ],
      ),
    );
  }
}
