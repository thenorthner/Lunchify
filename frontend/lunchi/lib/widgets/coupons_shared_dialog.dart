import 'package:flutter/material.dart';

class CouponsSharedDialog extends StatelessWidget {
  const CouponsSharedDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Center checkmark icon with confetti
            const _SuccessIcon(),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Coupons Shared! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B), // Dark navy / slate
                fontSize: 20,
                fontWeight: FontWeight.w500, fontFamily: 'EBGaramond', fontStyle: FontStyle.italic,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Your coupons have been shared\nsuccessfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B), // Grey
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.maybePop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Blue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Great!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    
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

// ═════════════════════════════════════════════
// Success Icon with decorative circle + sparkles/dots
// ═════════════════════════════════════════════
class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background light green circle
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F4EA), // Light green background
              shape: BoxShape.circle,
            ),
          ),
          
          // Main Green Checkmark Circle
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF34A853), // Solid Green
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, color: Colors.white, size: 28),
            ),
          ),

          // Decorations (confetti/sparkles)
          // Top Left Orange Star
          Positioned(left: 30, top: 12, child: _star(const Color(0xFFF9AB00), 8)),
          // Top Right Blue Dot
          Positioned(right: 25, top: 25, child: _dot(4, const Color(0xFF4285F4))),
          // Top Right Green Rectangle (Confetti)
          Positioned(
            right: 15, 
            top: 35, 
            child: Transform.rotate(
              angle: 0.5, 
              child: _rect(8, 3, const Color(0xFF34A853))
            ),
          ),
          // Left Blue Dot
          Positioned(left: 15, top: 50, child: _dot(6, const Color(0xFF4285F4))),
          // Left Yellow Dash
          Positioned(
            left: 5, 
            top: 55, 
            child: Transform.rotate(
              angle: -0.4, 
              child: _rect(10, 3, const Color(0xFFF9AB00))
            ),
          ),
          // Bottom Left Green Dash
          Positioned(
            left: 20, 
            bottom: 30, 
            child: Transform.rotate(
              angle: 0.6, 
              child: _rect(10, 3, const Color(0xFF34A853))
            ),
          ),
          // Right Blue Dash
          Positioned(
            right: 5, 
            top: 60, 
            child: Transform.rotate(
              angle: -0.5, 
              child: _rect(10, 3, const Color(0xFF4285F4))
            ),
          ),
          // Bottom Right Yellow Dash
          Positioned(
            right: 20, 
            bottom: 25, 
            child: Transform.rotate(
              angle: 0.3, 
              child: _rect(8, 4, const Color(0xFFF9AB00))
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _rect(double width, double height, Color color) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );
      
  Widget _star(Color color, double size) => Icon(Icons.star_rounded, size: size, color: color);
}
