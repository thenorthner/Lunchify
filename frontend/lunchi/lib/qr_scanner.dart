import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A2E6E);
const _kAccent = Color(0xFF2563EB);
const _kBg     = Color(0xFFEAF2FF);
const _kLight  = Color(0xFFDBE9FF);

// ════════════════════════════════════════════════════════════════════════════
//  SCAN QR PAGE
// ════════════════════════════════════════════════════════════════════════════
class QRScannerPage extends StatefulWidget {
  final String scannerId;

  const QRScannerPage({super.key, required this.scannerId});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with TickerProviderStateMixin {
  // Scanning line animation
  late final AnimationController _scanCtrl;
  late final Animation<double>   _scanAnim;

  // Corner brackets pulse animation
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  // Scan result state
  String? scannedData;
  bool isProcessing = false;
  
  final _manualCtrl  = TextEditingController();
  late final AudioPlayer _audioPlayer;
  final MobileScannerController _cameraController = MobileScannerController(facing: CameraFacing.back);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Scanning line — moves top to bottom and repeats
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );

    // Corner brackets — subtle pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _manualCtrl.dispose();
    _audioPlayer.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing || capture.barcodes.isEmpty) return;

    setState(() {
      isProcessing = true;
      scannedData = capture.barcodes.first.rawValue;
    });

    _processQR(scannedData);
  }

  Future<void> _processQR(String? code) async {
    if (code == null || !code.startsWith('QR_')) {
      showSnack("❌ Invalid QR code.");
      return resetProcessing();
    }

    final parts = code.split('|');
    if (parts.length != 4) {
      showSnack("❌ Invalid QR format.");
      return resetProcessing();
    }

    final qrData = code;
    final qrDate = parts[3];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (qrDate != today) {
      showSnack("❌ QR is not valid for today.");
      return resetProcessing();
    }

    // 🔁 Send to backend
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/qr/scan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: json.encode({
          'qrData': qrData,
          'scannerId': widget.scannerId,
        }),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        _scanCtrl.stop();
        _showSuccessDialog(body);
      } else {
        showSnack("❌ ${body['message'] ?? 'Scan failed'}");
        resetProcessing();
      }
    } catch (e) {
      showSnack("❌ Network error: $e");
      resetProcessing();
    }
  }

  void _showSuccessDialog(Map<String, dynamic> body) async {
    final employee = body['employee'] ?? {};
    
    List<dynamic> items = [];
    if (body['items'] != null) {
      if (body['items'] is String) {
        try {
          items = jsonDecode(body['items']);
        } catch (_) {}
      } else if (body['items'] is List) {
        items = body['items'];
      }
    }
    
    final employeeName = employee['name'] ?? 'Unknown';
    final employeeIdDisplay = employee['id'] ?? employee['employee_id'] ?? '';

    try {
      await _audioPlayer.play(AssetSource('audio/applepay.mp3'));
    } catch (e) {
      debugPrint('Audio play failed: $e');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sparkling Header Icon
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sparkles (using Positioned dots/icons)
                  Positioned(top: 15, left: 15, child: Transform.rotate(angle: -0.5, child: const Icon(Icons.horizontal_rule, size: 14, color: Color(0xFF22C55E)))),
                  Positioned(top: 25, right: 20, child: const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B))),
                  Positioned(bottom: 25, left: 15, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF87171), shape: BoxShape.circle))),
                  Positioned(bottom: 35, right: 10, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFC084FC), shape: BoxShape.circle))),
                  Positioned(top: 45, right: 5, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle))),
                  
                  // Main circle
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.15),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF), // very light blue
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Color(0xFF2563EB),
                        size: 40,
                      ),
                    ),
                  ),
                  
                  // Green check badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                        weight: 800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'QR Scanned!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lunch recorded successfully\nfor $employeeName ($employeeIdDisplay)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Recorded Meal Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recorded Meal",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items.isNotEmpty ? "${items[0]['quantity']}x ${items[0]['name']}" : "1x Food Lunch",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Scan Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetProcessing();
                  _scanCtrl.repeat();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Scan Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
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



  void showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE02020),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void resetProcessing() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────────
            _TopBar(),

            // ── Camera Viewfinder ─────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  // Actual camera background
                  Positioned.fill(
                    child: MobileScanner(
                      controller: _cameraController,
                      onDetect: _onDetect,
                    ),
                  ),

                  // Semi-transparent overlay with cutout
                  Positioned.fill(
                    child: _ScanOverlay(
                      scanAnim: _scanAnim,
                      pulseAnim: _pulseAnim,
                    ),
                  ),

                  // "Place QR within frame" pill
                  Positioned(
                    bottom: 24,
                    left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              color: _kAccent, size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Place the QR code within the frame',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A2340),
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

            // ── Bottom Panel ──────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F7FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR icon
                    Container(
                      width: 56, height: 56,
                      decoration: const BoxDecoration(
                        color: _kLight, shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: _kAccent, size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan a QR code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Position the QR code inside the frame to scan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8A96A8),
                      ),
                    ),
                    const SizedBox(height: 10),
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

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 34),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BackButton(),
                const SizedBox(width: 10),
                const Text(
                  'Scan QR to Record Lunch',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
                    letterSpacing: -0.2,
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
  late final Animation<double> _slide, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<double>(begin: 0, end: -4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kNavy.withOpacity(0.1),
                    blurRadius: 8, offset: const Offset(0, 2),
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

// ─── Scan Overlay with animated line + corner brackets ───────────────────────
class _ScanOverlay extends StatelessWidget {
  final Animation<double> scanAnim;
  final Animation<double> pulseAnim;

  const _ScanOverlay({
    required this.scanAnim,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Frame size and position
        final frameSize = w * 0.65;
        final frameLeft = (w - frameSize) / 2;
        final frameTop  = (h - frameSize) / 2 - 20;

        return Stack(
          children: [
            // Dark overlay — top
            Positioned(
              top: 0, left: 0, right: 0,
              height: frameTop,
              child: Container(color: Colors.black54),
            ),
            // Dark overlay — bottom
            Positioned(
              top: frameTop + frameSize, left: 0, right: 0,
              bottom: 0,
              child: Container(color: Colors.black54),
            ),
            // Dark overlay — left
            Positioned(
              top: frameTop, left: 0,
              width: frameLeft,
              height: frameSize,
              child: Container(color: Colors.black54),
            ),
            // Dark overlay — right
            Positioned(
              top: frameTop, right: 0,
              width: frameLeft,
              height: frameSize,
              child: Container(color: Colors.black54),
            ),

            // Corner brackets (animated pulse)
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) => Positioned(
                top: frameTop, left: frameLeft,
                width: frameSize, height: frameSize,
                child: Transform.scale(
                  scale: pulseAnim.value,
                  child: CustomPaint(
                    painter: _CornerBracketsPainter(),
                  ),
                ),
              ),
            ),

            // Animated scanning line
            AnimatedBuilder(
              animation: scanAnim,
              builder: (_, __) {
                final lineY = frameTop + (frameSize * scanAnim.value);
                return Positioned(
                  top: lineY,
                  left: frameLeft + 8,
                  width: frameSize - 16,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _kAccent.withOpacity(0),
                          _kAccent,
                          _kAccent.withOpacity(0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: _kAccent.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ─── Corner Brackets Painter ──────────────────────────────────────────────────
class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 28.0; // bracket arm length

    // Top-left
    canvas.drawLine(Offset(0, len), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(len, 0), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - len, size.height),
      Offset(size.width, size.height), paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - len),
      Offset(size.width, size.height), paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

