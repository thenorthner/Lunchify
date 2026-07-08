import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lunchi/config.dart';
import 'package:lunchi/auth_service.dart';
import 'dart:async';
import 'widgets/item_selection_sheet.dart';
import 'package:lunchi/app_theme.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'widgets/confirm_order_dialog.dart';
import 'widgets/success_dialog.dart';

class BuyLunchQrPage extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const BuyLunchQrPage({
    Key? key,
    required this.employeeId,
    required this.employeeName,
  }) : super(key: key);

  @override
  State<BuyLunchQrPage> createState() => _BuyLunchQrPageState();
}

class _BuyLunchQrPageState extends State<BuyLunchQrPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String? qrToken;
  Uint8List? serverQrImage;
  DateTime? qrExpiresAt;
  Timer? _statusTimer;
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _shareQrCode() async {
    try {
      if (_qrKey.currentContext == null) return;
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/lunchify_qr.png');
      await file.writeAsBytes(pngBytes);
      
      final xFile = XFile(file.path);

      final RenderBox? box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [xFile],
        text:
            '${AuthService.name} (${AuthService.employeeId}) Shared a Lunchify QR Dated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing QR Code: $e')));
      }
    }
  }

  List<String> todayFoodMenu = [];
  List<String> todayFruitMenu = [];

  String _url(String path) => '${AppConfig.apiBaseUrl}$path';

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final headers = {'Authorization': 'Bearer ${AuthService.token}'};

      final res = await Future.wait([
        http.get(Uri.parse(AppConfig.foodMenuByDate(date)), headers: headers),
        http.get(Uri.parse(AppConfig.fruitMenuByDate(date)), headers: headers),
      ]);

      if (res[0].statusCode == 200) {
        final decoded = _safeJsonDecodeRaw(res[0]);
        todayFoodMenu = _extractList(decoded, 'items');
      }
      if (res[1].statusCode == 200) {
        final decoded = _safeJsonDecodeRaw(res[1]);
        todayFruitMenu = _extractList(decoded, 'fruits');
        if (todayFruitMenu.isEmpty) {
          todayFruitMenu = _extractList(decoded, 'items');
        }
      }
    } catch (e) {
      debugPrint("Error fetching menus: $e");
    }
  }

  dynamic _safeJsonDecodeRaw(http.Response res) {
    final raw = res.body.trimLeft();
    if (raw.startsWith('<')) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }

  List<String> _extractList(dynamic body, String key) {
    if (body == null) return [];
    if (body is List) return body.map((e) => e.toString()).toList();
    if (body is Map && body[key] is List) {
      return List<String>.from(body[key]);
    }
    return [];
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _decodeJsonOrThrow(
    http.Response resp, {
    String? endpointHint,
  }) {
    final ct = (resp.headers['content-type'] ?? '').toLowerCase();
    final bodyText = resp.body;
    final preview = bodyText.substring(
      0,
      bodyText.length > 300 ? 300 : bodyText.length,
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: $preview');
    }
    if (!ct.contains('application/json')) {
      throw Exception('Expected JSON but got "$ct". Body: $preview');
    }
    final decoded = jsonDecode(bodyText);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Expected JSON object but got: ${decoded.runtimeType}');
  }

  Future<void> _generateOrRegenerateQr({Map<String, int>? items}) async {
    setState(() => isLoading = true);
    try {
      final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final resp = await http
          .post(
            Uri.parse(_url('/api/qr/generate-qr')),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${AuthService.token}',
            },
            body: jsonEncode({
              'employeeId': widget.employeeId,
              'type': 'food',
              'date': todayDate,
              if (items != null) 'items': _mapToList(items),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = _decodeJsonOrThrow(
        resp,
        endpointHint: '/api/qr/generate-qr',
      );

      if (body['success'] == true) {
        setState(() {
          qrToken = body['qrData'];
          if (body['qrImage'] != null) {
            final qrImageVal = body['qrImage'].toString();
            final base64String = qrImageVal.contains(',')
                ? qrImageVal.split(',').last
                : qrImageVal;
            serverQrImage = base64Decode(base64String);
          } else {
            serverQrImage = null;
          }
          qrExpiresAt = DateTime.now().add(const Duration(hours: 1));
        });
        _startStatusPolling();
      } else {
        _showInfoDialog('Failed', body['message'] ?? 'Could not generate QR.');
      }
    } catch (e) {
      _showInfoDialog('Error', 'Request failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showFruitLunchOrderDialog() async {
    final now = DateTime.now();
    if (now.hour >= 19) {
      _showInfoDialog(
        'Orders Closed',
        'Fruit lunch orders must be placed before 7:00 PM.',
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ConfirmOrderDialog(
        title: 'Confirm Order',
        message: "Let's secure the fruit munchies,\nshall we? 🍎😋",
        cancelText: 'Panic & Exit',
        confirmText: 'Lock It In.',
      ),
    );

    if (confirm != true) return;

    final items = todayFruitMenu.fold<Map<String, int>>({}, (map, item) {
      map[item] = 1;
      return map;
    });
    await _placeFruitLunchOrder(items);
  }

  Future<void> _placeFruitLunchOrder(Map<String, int> selectedItems) async {
    setState(() => isLoading = true);
    try {
      final itemsList = _mapToList(selectedItems);

      final resp = await http.post(
        Uri.parse(_url('/api/fruit-lunch-orders/order-fruit-lunch')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'employeeId': widget.employeeId,
          'name': widget.employeeName,
          'quantity': 1,
          'items': itemsList,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        }),
      );

      final body = _decodeJsonOrThrow(
        resp,
        endpointHint: '/api/fruit-lunch-orders/order-fruit-lunch',
      );

      _showInfoDialog(
        body['success'] == true ? 'Success' : 'Failed',
        body['message']?.toString() ??
            'A Wise Choice Was Made 🗿. \n Food Secured 🔥',
      );
    } catch (e) {
      _showInfoDialog('Error', e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showFoodLunchOrderDialog() async {
    // Skip item selection and generate QR directly
    final items = todayFoodMenu.fold<Map<String, int>>({}, (map, item) {
      map[item] = 1;
      return map;
    });
    await _generateOrRegenerateQr(items: items);
  }

  List<Map<String, dynamic>> _mapToList(Map<String, int> map) {
    return map.entries
        .map((e) => {"name": e.key, "quantity": e.value})
        .toList();
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkQrStatus(),
    );
  }

  Future<void> _checkQrStatus() async {
    if (qrToken == null) return;
    try {
      final resp = await http.post(
        Uri.parse(_url('/api/qr/status')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'qrToken': qrToken}),
      );

      final body = _decodeJsonOrThrow(resp, endpointHint: '/api/qr/status');

      if (body['scanned'] == true) {
        _statusTimer?.cancel();
        setState(() {
          qrToken = null;
          serverQrImage = null;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('QR poll error: $e');
    }
  }

  Future<void> _cancelQr() async {
    if (qrToken == null) return;
    try {
      setState(() => isLoading = true);
      final resp = await http.post(
        Uri.parse(_url('/api/qr/cancel')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'employeeId': widget.employeeId, 'qrToken': qrToken}),
      );

      try {
        _decodeJsonOrThrow(resp, endpointHint: '/api/qr/cancel');
      } catch (e) {
        debugPrint('Cancel QR response issue: $e');
      }

      setState(() {
        qrToken = null;
        serverQrImage = null;
      });
      _statusTimer?.cancel();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showInfoDialog(String title, String message) {
    if (title == 'Success') {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessDialog(
          title: "Success",
          message: "A Wise Choice Was Made 🦉.\nFood Secured 🔥",
          buttonText: "Naturally😏",
        ),
      );
    }
    
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: kAccentBlue),
            child: const Text(
              'Got it',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with sparkles and glowing check
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Faint clouds background
                  Positioned(left: -20, bottom: 0, child: Icon(Icons.cloud, color: Colors.blue.withOpacity(0.04), size: 80)),
                  Positioned(right: -20, bottom: 10, child: Icon(Icons.cloud, color: Colors.blue.withOpacity(0.04), size: 60)),
                  
                  // Sparkles (using Positioned dots/icons)
                  Positioned(top: 15, left: 30, child: const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B))),
                  Positioned(top: 25, right: 30, child: Transform.rotate(angle: 0.5, child: const Icon(Icons.horizontal_rule, size: 14, color: Color(0xFF3B82F6)))),
                  Positioned(bottom: 25, left: 40, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle))),
                  Positioned(bottom: 35, right: 40, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF87171), shape: BoxShape.circle))),
                  Positioned(top: 50, left: 50, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFC084FC), shape: BoxShape.circle))),
                  
                  // Main glowing circle
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDCFCE7).withOpacity(0.4),
                    ),
                    child: Center(
                      child: Container(
                        width: 64, height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x5522C55E), blurRadius: 16, spreadRadius: 4)
                          ]
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 42,
                          weight: 800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lunch Purchased\nSuccessfully! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A), // kNavy equivalent
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            
            // Divider with verified badge
            Row(
              children: [
                Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Icon(Icons.verified, size: 22, color: Color(0xFF2563EB)),
                ),
                Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Enjoy your meal!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5, fontFamily: 'PlusJakartaSans'),
                children: [
                  TextSpan(text: 'Your lunch coupon has been\n'),
                  TextSpan(text: 'verified and redeemed.', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                ]
              )
            ),
            const SizedBox(height: 28),
            
            // Great Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Great!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _formattedExpiry {
    if (qrExpiresAt == null) return '';
    final d = qrExpiresAt!;
    final hour = d.hour > 12
        ? d.hour - 12
        : d.hour == 0
        ? 12
        : d.hour;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day}/${d.year} $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final bool expired = false; // Expiration removed
    final bool qrVisible = qrToken != null;

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimaryBlue),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Fruit Lunch row card ──────────────────────────────────
                          if (!qrVisible)
                            _ActionCard(
                              icon: Icons.set_meal_rounded,
                              title: 'Fruit Lunch',
                              subtitle: 'Choose healthy & fresh options',
                              onTap: _showFruitLunchOrderDialog,
                            ),

                          if (!qrVisible) const SizedBox(height: 14),

                          // ── Food Lunch / Regenerate QR row card ────────────────────
                          if (!qrVisible)
                            _ActionCard(
                              icon: Icons.restaurant_rounded,
                              title: 'Food Lunch',
                              subtitle: 'Generate a QR code for lunch',
                              onTap: _showFoodLunchOrderDialog,
                            )
                          else
                            _ActionCard(
                              icon: Icons.sync_rounded,
                              title: 'Regenerate QR',
                              subtitle: 'Generate a new QR code',
                              onTap: _generateOrRegenerateQr,
                            ),

                          if (qrVisible) ...[
                            const SizedBox(height: 20),

                            // ── Info banner ───────────────────────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: kPillBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: kBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.verified_user_rounded,
                                    color: kAccentBlue,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Show this QR to admin. It is valid for one scan only.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: kNavy,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── QR Code box ───────────────────────────────────────────
                            AnimatedOpacity(
                              opacity: expired ? 0.3 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Center(
                                child: RepaintBoundary(
                                  key: _qrKey,
                                  child: Container(
                                    width: 220,
                                    height: 220,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: kCardWhite,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kBlue.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: serverQrImage != null
                                        ? Image.memory(
                                            serverQrImage!,
                                            width: 200,
                                            height: 200,
                                          )
                                        : QrImageView(
                                            data: qrToken ?? '',
                                            version: QrVersions.auto,
                                            size: 200,
                                            eyeStyle: const QrEyeStyle(
                                              eyeShape: QrEyeShape.square,
                                              color: kNavy,
                                            ),
                                            dataModuleStyle:
                                                const QrDataModuleStyle(
                                                  dataModuleShape:
                                                      QrDataModuleShape.square,
                                                  color: kNavy,
                                                ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _cancelQr,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: kAccentBlue,
                                      side: const BorderSide(color: kAccentBlue, width: 1.5),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel QR',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _shareQrCode,
                                    icon: const Icon(Icons.share, size: 20),
                                    label: const Text(
                                      'Share QR',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kAccentBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Important Note banner ─────────────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: kCardWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: kBlue.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: kAccentBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified_user_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Important Note',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: kNavy,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'This QR code can be used for a single scan only and cannot be reused.',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: kSubtext,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
      height: 130,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
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
              'assets/images/food_tray_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFD0DCF0)),
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
                    Color(0xF5EAF2FF),
                    Color(0xCCEAF2FF),
                    Color(0x55EAF2FF),
                    Color(0x05EAF2FF),
                  ],
                ),
              ),
            ),
          ),
          // Back button + title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BackButton(),
                const SizedBox(width: 10),
                const Text(
                  'Redeem Coupon',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: kNavy,
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
    _slide = Tween<double>(
      begin: 0,
      end: -4,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
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
      onExit: (_) => _ctrl.reverse(),
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
                    color: kNavy.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: kNavy, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Action Card (Fruit Lunch / Regenerate QR rows) ──────────────────────────
class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: kCardWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: kBlue.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: kLightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: kAccentBlue, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kNavy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(fontSize: 13, color: kSubtext),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: kAccentBlue,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A2E6E), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2E6E).withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────
class _OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kAccentBlue, width: 1.8),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kAccentBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
