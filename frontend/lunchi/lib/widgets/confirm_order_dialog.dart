import 'package:flutter/material.dart';

class ConfirmOrderDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  const ConfirmOrderDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 340,
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
                    colors: [Color(0xFFEFF6FF), Colors.white], // Light blue to white
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Decorative Confetti Dots
            Positioned(top: 50, left: 60, child: _buildDot(const Color(0xFFFBBF24), 6)),
            Positioned(top: 70, left: 40, child: _buildDot(const Color(0xFF93C5FD), 8)),
            Positioned(top: 30, right: 80, child: _buildDot(const Color(0xFF6EE7B7), 6)),
            Positioned(top: 60, right: 50, child: _buildDot(const Color(0xFFFBBF24), 8)),
            Positioned(top: 80, right: 80, child: _buildDot(const Color(0xFF93C5FD), 6)),
            
            // Cloud shapes
            Positioned(top: 100, left: -20, child: _buildCloud(90)),
            Positioned(top: 90, right: -20, child: _buildCloud(110)),
            Positioned(top: 110, left: 40, child: _buildCloud(80)),
            Positioned(top: 100, right: 40, child: _buildCloud(90)),
            Positioned(top: 120, left: 100, child: _buildCloud(100)),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  
                  // Shield icon with glow
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB), // Blue background
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
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
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider with shield
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: const Color(0xFFBFDBFE).withOpacity(0.5), thickness: 1.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: const Icon(Icons.shield, color: Color(0xFF93C5FD), size: 20),
                      ),
                      Expanded(
                        child: Divider(color: const Color(0xFFBFDBFE).withOpacity(0.5), thickness: 1.5),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475569),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_run_rounded, color: Color(0xFF2563EB), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                cancelText,
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Confirm Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  confirmText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
