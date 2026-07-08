import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dart:math' as math;

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeInOutSine)),
    );
    
    _controller.forward();

    // Loop floating animation slightly by oscillating
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // We could loop a separate controller for floating, but keeping it simple
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2FB),
      body: Stack(
        children: [
          // 1. Clean light-blue gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE2F0FD), Color(0xFFB9D8F6)],
              ),
            ),
          ),
          
          // Faint Clouds in background
          Positioned(
            left: 20,
            top: 200,
            child: _buildCloud(opacity: 0.4, scale: 0.8),
          ),
          Positioned(
            right: -20,
            top: 150,
            child: _buildCloud(opacity: 0.3, scale: 1.2),
          ),
          Positioned(
            left: -40,
            bottom: 300,
            child: _buildCloud(opacity: 0.5, scale: 1.5),
          ),
          Positioned(
            right: 40,
            bottom: 250,
            child: _buildCloud(opacity: 0.4, scale: 1.0),
          ),

          // Main content in FadeTransition
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo with surrounding floating icons
                  SizedBox(
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Floating Custom Icons (Left and Right)
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            final dy = math.sin(_floatAnimation.value * math.pi * 2) * 8; // 8px float up and down
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  left: 20,
                                  top: 50 + dy,
                                  child: Image.asset(
                                    'assets/images/floating_icons_2.png',
                                    height: 100,
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                                Positioned(
                                  right: 15,
                                  top: 10 - dy, // moves opposite
                                  child: Image.asset(
                                    'assets/images/floating_icons_1.png',
                                    height: 180,
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        
                        // Main Logo Circle
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(28),
                            child: Image.asset(
                              'assets/images/lunchify_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.restaurant, size: 60, color: kPrimaryBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Text elements
                  const Text(
                    "LUNCHIFY",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E3A8A), // Dark blue
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 1.5,
                        color: const Color(0xFF93C5FD),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.favorite, color: Color(0xFF3B82F6), size: 14),
                      ),
                      Container(
                        width: 40,
                        height: 1.5,
                        color: const Color(0xFF93C5FD),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    "SJVN Employee Meal Services",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    "Smart meals. Happy employees. Stronger together.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
          
          // 3D Food Tray with ShaderMask to blend top edge smoothly
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black, Colors.black],
                    stops: [0.0, 0.25, 1.0], // Fade out the top 25% to blend with background
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/food_tray_bg.png',
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 200),
                ),
              ),
            ),
          ),
          
          // Footer Pill & Dots
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Shield with lightning bolt
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.shield, color: Color(0xFF2563EB), size: 20),
                              const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Powering better meals, every day.",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud({required double opacity, required double scale}) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 120,
          height: 60,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 25,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 30,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.4);
    // Smooth wave shape
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
