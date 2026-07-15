import 'package:flutter/material.dart';
import '../app_theme.dart';

class SuccessShareDialog extends StatelessWidget {
  const SuccessShareDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with confetti
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Confetti Dots & Lines
                  Positioned(top: 15, left: 20, child: _buildDot(Colors.yellow, 6)),
                  Positioned(top: 25, right: 30, child: _buildDot(Colors.blue, 6)),
                  Positioned(bottom: 25, left: 30, child: _buildDot(Colors.green, 6)),
                  Positioned(bottom: 15, right: 25, child: _buildDot(Colors.yellow.shade600, 6)),
                  
                  Positioned(top: 30, left: 45, child: _buildDash(Colors.green, -0.5)),
                  Positioned(top: 40, right: 40, child: _buildDash(Colors.green, 0.5)),
                  Positioned(bottom: 35, left: 20, child: _buildDash(Colors.yellow, 0.8)),
                  Positioned(bottom: 45, right: 20, child: _buildDash(Colors.blue, -0.8)),

                  // Outer light green circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      // Inner darker green circle
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E), // exact green shade
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 32,
                            weight: 700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Title
            const Text(
              "Coupons Shared! 🎉",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E3A8A), // darker blue
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Subtitle
            const Text(
              "Your coupons have been shared\nsuccessfully.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Great!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDash(Color color, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 12,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
