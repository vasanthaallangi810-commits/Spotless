import 'dart:math';

import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _getStarted() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // =====================================================
          // BACKGROUND
          // =====================================================

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A3323),
                  Color(0xFF105E43),
                  Color(0xFF839958),
                  Color(0xFFF7F4D5),
                ],
              ),
            ),
          ),

          // =====================================================
          // FLOATING ENVIRONMENT ICONS
          // =====================================================

          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Stack(
                children: [
                  _floatingIcon(
                    icon: Icons.eco,
                    left: 35,
                    top: 110,
                    size: 38,
                    phase: 0,
                  ),

                  _floatingIcon(
                    icon: Icons.recycling,
                    right: 35,
                    top: 160,
                    size: 44,
                    phase: 1,
                  ),

                  _floatingIcon(
                    icon: Icons.water_drop,
                    left: 65,
                    top: 350,
                    size: 32,
                    phase: 2,
                  ),

                  _floatingIcon(
                    icon: Icons.local_florist,
                    right: 70,
                    top: 410,
                    size: 35,
                    phase: 3,
                  ),

                  _floatingIcon(
                    icon: Icons.energy_savings_leaf,
                    left: 25,
                    bottom: 190,
                    size: 42,
                    phase: 4,
                  ),

                  _floatingIcon(
                    icon: Icons.delete_outline,
                    right: 35,
                    bottom: 250,
                    size: 40,
                    phase: 5,
                  ),

                  _floatingIcon(
                    icon: Icons.public,
                    left: 120,
                    bottom: 110,
                    size: 30,
                    phase: 6,
                  ),

                  _floatingIcon(
                    icon: Icons.nature_people,
                    right: 115,
                    bottom: 100,
                    size: 35,
                    phase: 7,
                  ),
                ],
              );
            },
          ),

          // =====================================================
          // MAIN CONTENT
          // =====================================================

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale =
                            1 + (_pulseController.value * 0.05);

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF7F4D5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.eco,
                              size: 75,
                              color: Color(0xFF0A3323),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'SPOTLESS',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: Color(0xFFF7F4D5),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Cleaner surroundings.\nA better tomorrow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Color(0xFFE8E8C7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 70),

                    // =================================================
                    // SLIDE BUTTON
                    // =================================================

                    SlideToStart(
                      onComplete: _getStarted,
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Report • Track • Clean',
                      style: TextStyle(
                        color: Color(0xFFE8E8C7),
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingIcon({
    required IconData icon,
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required int phase,
  }) {
    final movement =
        sin((_floatController.value * 2 * pi) + phase) * 12;

    return Positioned(
      left: left,
      right: right,
      top: top != null ? top + movement : null,
      bottom: bottom != null ? bottom + movement : null,
      child: Opacity(
        opacity: 0.55,
        child: Icon(
          icon,
          size: size,
          color: const Color(0xFFF7F4D5),
        ),
      ),
    );
  }
}

// ===============================================================
// SLIDE TO START WIDGET
// ===============================================================

class SlideToStart extends StatefulWidget {
  final VoidCallback onComplete;

  const SlideToStart({
    super.key,
    required this.onComplete,
  });

  @override
  State<SlideToStart> createState() => _SlideToStartState();
}

class _SlideToStartState extends State<SlideToStart> {
  double _position = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const buttonSize = 58.0;

        final maxPosition = width - buttonSize;

        return Container(
          height: 68,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0A3323).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: const Color(0xFFF7F4D5).withValues(alpha: 0.35),
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  'SLIDE TO GET STARTED  →',
                  style: TextStyle(
                    color: const Color(0xFFF7F4D5).withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 120),
                left: _position,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _position += details.delta.dx;

                      if (_position < 0) {
                        _position = 0;
                      }

                      if (_position > maxPosition) {
                        _position = maxPosition;
                      }
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_position > maxPosition * 0.75) {
                      widget.onComplete();
                    } else {
                      setState(() {
                        _position = 0;
                      });
                    }
                  },
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    margin: const EdgeInsets.only(left: 5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF7F4D5),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0A3323),
                      size: 27,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}