import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SpotlessBackground extends StatefulWidget {
  final Widget child;
  final bool dark;

  const SpotlessBackground({
    super.key,
    required this.child,
    this.dark = false,
  });

  @override
  State<SpotlessBackground> createState() =>
      _SpotlessBackgroundState();
}

class _SpotlessBackgroundState
    extends State<SpotlessBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  final Random random = Random(42);

  final List<IconData> icons = [
    Icons.eco,
    Icons.eco_outlined,
    Icons.recycling,
    Icons.spa,
    Icons.local_florist,
    Icons.water_drop_outlined,
    Icons.auto_awesome,
    Icons.star_outline,
    Icons.energy_savings_leaf,
    Icons.grass,
    Icons.yard,
    Icons.forest,
    Icons.eco,
    Icons.recycling,
    Icons.spa,
    Icons.local_florist,
    Icons.auto_awesome,
    Icons.water_drop_outlined,
    Icons.grass,
    Icons.eco,
    Icons.recycling,
    Icons.star_outline,
    Icons.yard,
    Icons.spa,
    Icons.energy_savings_leaf,
    Icons.eco,
    Icons.local_florist,
    Icons.recycling,
    Icons.grass,
    Icons.auto_awesome,
    Icons.eco,
    Icons.water_drop_outlined,
    Icons.spa,
    Icons.recycling,
    Icons.yard,
  ];

  late final List<_FloatingObject> objects;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    objects = List.generate(
      icons.length,
      (index) {
        return _FloatingObject(
          icon: icons[index],
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 15 + random.nextDouble() * 30,
          phase: random.nextDouble() * pi * 2,
          speed: 0.5 + random.nextDouble() * 1.5,
          rotation: random.nextDouble() * pi,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.beige,
                      Color(0xFFE9E7C8),
                      AppTheme.beige,
                    ],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Stack(
                  children: objects.map((object) {
                    final wave = sin(
                      controller.value *
                              pi *
                              2 *
                              object.speed +
                          object.phase,
                    );

                    final wave2 = cos(
                      controller.value *
                              pi *
                              2 *
                              object.speed +
                          object.phase,
                    );

                    final left =
                        object.x * constraints.maxWidth +
                            wave * 22;

                    final top =
                        object.y * constraints.maxHeight +
                            wave2 * 25;

                    return Positioned(
                      left: left,
                      top: top,
                      child: Transform.rotate(
                        angle:
                            object.rotation +
                                wave * 0.25,
                        child: Opacity(
                          opacity: widget.dark
                              ? 0.16
                              : 0.20,
                          child: Icon(
                            object.icon,
                            size: object.size,
                            color: indexColor(
                              object.icon,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            widget.child,
          ],
        );
      },
    );
  }

  Color indexColor(IconData icon) {
    if (icon == Icons.auto_awesome ||
        icon == Icons.star_outline) {
      return AppTheme.rosyBrown;
    }

    if (icon == Icons.water_drop_outlined) {
      return AppTheme.midnightGreen;
    }

    return AppTheme.mossGreen;
  }
}

class _FloatingObject {
  final IconData icon;
  final double x;
  final double y;
  final double size;
  final double phase;
  final double speed;
  final double rotation;

  _FloatingObject({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.speed,
    required this.rotation,
  });
}