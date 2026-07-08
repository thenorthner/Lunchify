import 'package:flutter/material.dart';
import 'package:lunchi/lunch_rating_selection_screen.dart';
import 'package:lunchi/feedback_page.dart';
import 'widgets/top_bar.dart'; // Ensure you have this or just use an AppBar
import 'dart:math' as math;

class SupportRatingsHub extends StatelessWidget {
  const SupportRatingsHub({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kBgColor = Color(0xFFF8FAFC);
    
    return Scaffold(
      backgroundColor: kBgColor,
      body: Stack(
        children: [
          // Background Bottom Wave
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _SupportBottomWaveClipper(),
              child: Container(
                height: 150,
                color: const Color(0xFFE8F2FB), // Light curvy wave color
              ),
            ),
          ),
          
          Column(
            children: [
              // Custom Header
              Container(
                height: 190, // Increased height to prevent overlap
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A3A8F).withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/food_tray_bg.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE3F2FD)),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withOpacity(0.98),
                                Colors.white.withOpacity(0.85),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1A3A8F)),
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                "Rating & Feedback",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A2E6E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Help us serve you better 💙",
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _HubCard(
                      icon: Icons.star_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: "Menu Rating",
                      subtitle: "Rate today's lunch menu",
                      pillIcon: Icons.star_rounded,
                      pillText: "Your feedback matters",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LunchRatingSelectionScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _HubCard(
                      icon: Icons.bug_report_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: "Report a Bug",
                      subtitle: "Found something broken?\nLet the IT team know",
                      pillIcon: Icons.verified_user_rounded,
                      pillText: "We'll take care of it",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbackPage()),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Bottom Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC).withOpacity(0.8), // Slightly transparent to let wave show
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF2563EB), size: 28),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your feedback helps us improve",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Thank you for being a part of our community!",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Right side faint sparkles and heart
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -10,
                                left: -10,
                                child: Icon(Icons.auto_awesome, color: const Color(0xFFBFDBFE).withOpacity(0.5), size: 12),
                              ),
                              Positioned(
                                bottom: -5,
                                right: -5,
                                child: Icon(Icons.auto_awesome, color: const Color(0xFFBFDBFE).withOpacity(0.5), size: 10),
                              ),
                              const Icon(Icons.favorite, color: Color(0xFF2563EB), size: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final IconData pillIcon;
  final String pillText;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.pillIcon,
    required this.pillText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with Sparkles
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(icon, size: 36, color: iconColor),
                    ),
                  ),
                  // Decorative Sparkles
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Icon(Icons.star, size: 8, color: const Color(0xFF60A5FA).withOpacity(0.6)),
                  ),
                  Positioned(
                    top: 15,
                    right: 12,
                    child: Icon(Icons.star_border, size: 10, color: const Color(0xFFFBBF24).withOpacity(0.8)),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Icon(Icons.star, size: 10, color: const Color(0xFF93C5FD).withOpacity(0.8)),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 10,
                    child: Icon(Icons.star, size: 8, color: const Color(0xFFFCD34D).withOpacity(0.8)),
                  ),
                  Positioned(
                    top: 30,
                    left: 4,
                    child: Icon(Icons.auto_awesome, size: 8, color: const Color(0xFF2563EB).withOpacity(0.4)),
                  ),
                  Positioned(
                    bottom: 25,
                    right: 4,
                    child: Icon(Icons.auto_awesome, size: 10, color: const Color(0xFF3B82F6).withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(pillIcon, size: 14, color: const Color(0xFF3B82F6)),
                        const SizedBox(width: 4),
                        Text(
                          pillText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF3B82F6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportBottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
