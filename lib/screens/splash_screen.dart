import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 700;
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final maxContentWidth = isWideLayout ? 540.0 : 420.0;
        final titleSize = isWideLayout ? 52.0 : 42.0;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/eco_cleanup_vertical.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),

              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  final iconLayout = [
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
                    _floatingIcon(
                      icon: Icons.cleaning_services,
                      left: 80,
                      top: 230,
                      size: 31,
                      phase: 8,
                    ),
                    _floatingIcon(
                      icon: Icons.delete_forever,
                      right: 85,
                      top: 280,
                      size: 33,
                      phase: 9,
                    ),
                    _floatingIcon(
                      icon: Icons.checklist_rtl,
                      left: 150,
                      bottom: 180,
                      size: 29,
                      phase: 10,
                    ),
                    _floatingIcon(
                      icon: Icons.forest,
                      right: 150,
                      bottom: 170,
                      size: 30,
                      phase: 11,
                    ),
                    _floatingIcon(
                      icon: Icons.auto_awesome,
                      left: 200,
                      top: 80,
                      size: 28,
                      phase: 12,
                    ),
                    _floatingIcon(
                      icon: Icons.spa,
                      right: 190,
                      top: 90,
                      size: 29,
                      phase: 13,
                    ),
                    _floatingIcon(
                      icon: Icons.recycling,
                      left: 230,
                      top: 470,
                      size: 26,
                      phase: 14,
                    ),
                    _floatingIcon(
                      icon: Icons.eco,
                      right: 205,
                      top: 500,
                      size: 25,
                      phase: 15,
                    ),
                    _floatingIcon(
                      icon: Icons.public,
                      left: 290,
                      bottom: 120,
                      size: 28,
                      phase: 16,
                    ),
                    _floatingIcon(
                      icon: Icons.security,
                      right: 260,
                      bottom: 140,
                      size: 27,
                      phase: 17,
                    ),
                    _floatingIcon(
                      icon: Icons.sunny,
                      left: 20,
                      top: 500,
                      size: 24,
                      phase: 18,
                    ),
                    _floatingIcon(
                      icon: Icons.grass,
                      right: 30,
                      top: 520,
                      size: 24,
                      phase: 19,
                    ),
                  ];

                  return Stack(children: iconLayout);
                },
              ),

              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale =
                                  1 + (_pulseController.value * 0.05);

                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: isWideLayout ? 150 : 130,
                                  height: isWideLayout ? 150 : 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.beige,
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
                                    color: AppTheme.darkGreen,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 35),
                          Text(
                            'SPOTLESS',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                              color: AppTheme.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Cleaner surroundings.\nA better tomorrow.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: AppTheme.darkGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 70),
                          SlideToStart(
                            onComplete: _getStarted,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'Report • Track • Clean',
                            style: TextStyle(
                              color: AppTheme.darkGreen,
                              fontSize: 13,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildResponsiveBackground({
    required bool isLandscape,
    required double width,
    required double height,
  }) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/eco_cleanup_vertical.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
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
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.beige.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: size + 6,
          color: AppTheme.mossGreen,
          shadows: [
            Shadow(
              color: AppTheme.mossGreen.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
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
            color: AppTheme.beige.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: AppTheme.darkGreen.withValues(alpha: 0.22),
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  'SLIDE TO GET STARTED  →',
                  style: TextStyle(
                    color: AppTheme.darkGreen.withValues(alpha: 0.9),
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
                      color: AppTheme.darkGreen,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: AppTheme.beige,
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