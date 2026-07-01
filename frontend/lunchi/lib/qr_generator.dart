import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'config.dart';
import 'auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class QrGeneratorPage extends StatefulWidget {
  final String type; // food / fruit / snack

  const QrGeneratorPage({super.key, required this.type});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  final TextEditingController employeeIdController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();

  bool isLoading = false;
  String? qrData;
  String? errorMessage;

  Future<void> _shareQrCode() async {
    try {
      if (_qrKey.currentContext == null) return;
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await Share.shareXFiles(
        [XFile.fromData(pngBytes, mimeType: 'image/png', name: 'qr_code.png')],
        text: '${AuthService.name} (${AuthService.employeeId}) Shared a Lunchify QR Dated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing QR Code: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    employeeIdController.dispose();
    super.dispose();
  }

  String _preview(String s, [int n = 350]) =>
      s.substring(0, s.length > n ? n : s.length);

  Map<String, dynamic> _decodeJsonOrThrow(http.Response resp) {
    final ct = (resp.headers['content-type'] ?? '').toLowerCase();
    final raw = resp.body;
    final trimmed = raw.trimLeft();

    debugPrint('--- QR GENERATOR DEBUG ---');
    debugPrint('URL: ${AppConfig.generateQr}');
    debugPrint('STATUS: ${resp.statusCode}');
    debugPrint('CONTENT-TYPE: $ct');
    debugPrint('BODY(0..350): ${_preview(raw)}');
    debugPrint('--------------------------');

    // If the server returned HTML, jsonDecode will crash -> prevent it.
    if (trimmed.startsWith('<!doctype') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<')) {
      throw Exception(
        'Server returned HTML (not JSON). '
            'This usually means wrong endpoint or backend not reachable.',
      );
    }

    // Non-2xx -> show preview
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: ${_preview(raw)}');
    }

    // Some servers may not send content-type correctly; still allow decode if body is JSON-like.
    final looksJson = trimmed.startsWith('{') || trimmed.startsWith('[');
    if (!ct.contains('application/json') && !looksJson) {
      throw Exception('Expected JSON but got "$ct": ${_preview(raw)}');
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Expected JSON object but got ${decoded.runtimeType}');
  }

  Future<void> generateQr() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      qrData = null;
    });

    try {
      final employeeId = employeeIdController.text.trim();
      if (employeeId.isEmpty) {
        setState(() => errorMessage = 'Please enter Employee ID');
        return;
      }

      final response = await http.post(
        Uri.parse(AppConfig.generateQr), // ✅ uses config.dart
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'employeeId': employeeId,
          'type': widget.type, // 🔥 dynamic now
          'date': DateTime.now().toIso8601String().substring(0, 10),
        }),
      );

      final decoded = _decodeJsonOrThrow(response);

      // ✅ supports both backend formats:
      // A) { success:true, qrData:"..." }
      // B) { qrData:"..." }
      final hasSuccess = decoded.containsKey('success');
      final ok = hasSuccess ? decoded['success'] == true : true;

      if (ok && decoded['qrData'] != null) {
        setState(() => qrData = decoded['qrData'].toString());
      } else {
        setState(() {
          errorMessage =
              decoded['message']?.toString() ?? 'QR generation failed';
        });
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR'),
        backgroundColor: const Color(0xFFFF715B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : generateQr,
              child: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Generate QR'),
            ),
            const SizedBox(height: 30),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            if (qrData != null) ...[
              const SizedBox(height: 20),
              RepaintBoundary(
                key: _qrKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: QrImageView(data: qrData!, size: 220),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _shareQrCode,
                icon: const Icon(Icons.share),
                label: const Text('Share QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3730A3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
