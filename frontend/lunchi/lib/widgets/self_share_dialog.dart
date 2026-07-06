import 'package:flutter/material.dart';

class SelfShareDialog extends StatelessWidget {
  const SelfShareDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Top gradient area
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: Container(
                height: 160,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEBF4FF), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Decorative Confetti Dots
            Positioned(top: 50, left: 60, child: _buildDot(const Color(0xFFFDE047), 6)),
            Positioned(top: 70, left: 40, child: _buildDot(const Color(0xFF93C5FD), 8)),
            Positioned(top: 30, right: 80, child: _buildDot(const Color(0xFF6EE7B7), 6)),
            Positioned(top: 60, right: 50, child: _buildDot(const Color(0xFFFDE047), 8)),
            Positioned(top: 80, right: 80, child: _buildDot(const Color(0xFFFDBA74), 6)),
            
            // Cloud shapes for the bottom of the gradient
            Positioned(top: 100, left: -20, child: _buildCloud(90)),
            Positioned(top: 90, right: -20, child: _buildCloud(110)),
            Positioned(top: 110, left: 40, child: _buildCloud(80)),
            Positioned(top: 100, right: 40, child: _buildCloud(90)),
            Positioned(top: 120, left: 100, child: _buildCloud(100)),

            // Content
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  
                  // Gift icon with glow
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F4CDB),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F4CDB).withOpacity(0.3),
                          blurRadius: 28,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Hey Title with accents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "Hey!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 24),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    "You already own this coupon,\ngenius. 🫠",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF475569),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Divider with heart
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: const Color(0xFFBFDBFE).withOpacity(0.5), thickness: 1.5),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, color: Color(0xFF93C5FD), size: 14),
                      ),
                      Expanded(
                        child: Divider(color: const Color(0xFFBFDBFE).withOpacity(0.5), thickness: 1.5),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F4CDB), Color(0xFF1E3A8A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F4CDB).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "My bad 😅",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
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
}
