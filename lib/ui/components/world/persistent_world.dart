import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

class WorldIntensityController {
  static final ValueNotifier<bool> focusMode = ValueNotifier<bool>(false);

  static void setFocusMode(bool focused) {
    if (focusMode.value == focused) return;
    focusMode.value = focused;
  }
}

class PersistentWorld extends StatefulWidget {
  const PersistentWorld({super.key});

  @override
  State<PersistentWorld> createState() => _PersistentWorldState();
}

class _PersistentWorldState extends State<PersistentWorld> with TickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  )..repeat();

  late final AnimationController _particles = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  @override
  void dispose() {
    _ambient.dispose();
    _particles.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ValueListenableBuilder<bool>(
        valueListenable: WorldIntensityController.focusMode,
        builder: (context, focused, _) {
          final intensity = focused ? 0.72 : 1.0;
          return RepaintBoundary(
            child: Stack(
              children: [
                const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.background)),
                AnimatedBuilder(
                  animation: _ambient,
                  builder: (context, _) {
                    final drift = math.sin(_ambient.value * math.pi * 2) * intensity;
                    return Stack(
                      children: [
                        _blob(top: -90, left: -40, size: 240, color: AppColors.blob1, offset: Offset(drift * 18, 4), opacity: 0.2 * intensity),
                        _blob(top: 160, right: -80, size: 280, color: AppColors.blob2, offset: Offset(-drift * 24, drift * 9), opacity: 0.2 * intensity),
                        _blob(bottom: -110, left: 20, size: 280, color: AppColors.blob3, offset: Offset(drift * 12, -drift * 6), opacity: 0.2 * intensity),
                        _blob(bottom: 180, right: 26, size: 170, color: AppColors.blob1, offset: Offset(-drift * 8, drift * 6), opacity: 0.12 * intensity),
                      ],
                    );
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_particles, _twinkle]),
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _ParticlePainter(
                            flow: _particles.value,
                            twinkle: _twinkle.value,
                            intensity: intensity,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _GradientNoise(intensity: intensity),
                _Mascot(intensity: intensity),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _blob({
    required double size,
    required Color color,
    Offset offset = Offset.zero,
    double opacity = 0.2,
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.translate(
        offset: offset,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color.withOpacity(opacity), shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.flow, required this.twinkle, required this.intensity});

  final double flow;
  final double twinkle;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 40; i++) {
      final seed = i / 40;
      final x = size.width * ((seed * 0.9 + flow * (0.02 + seed * 0.04)) % 1);
      final y = size.height * ((seed * 1.7 + flow * (0.14 + seed * 0.10)) % 1);
      final pulse = (math.sin((twinkle + seed) * math.pi * 2) + 1) / 2;
      final radius = 0.8 + (pulse * 1.8 * intensity);
      final alpha = (0.03 + (pulse * 0.12)) * intensity;
      final paint = Paint()..color = Colors.white.withOpacity(alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.flow != flow || oldDelegate.twinkle != twinkle || oldDelegate.intensity != intensity;
  }
}

class _GradientNoise extends StatelessWidget {
  const _GradientNoise({required this.intensity});

  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.04 * intensity),
                Colors.transparent,
                Colors.black.withOpacity(0.09 * intensity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Mascot extends StatefulWidget {
  const _Mascot({required this.intensity});

  final double intensity;

  @override
  State<_Mascot> createState() => _MascotState();
}

class _MascotState extends State<_Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 18,
      bottom: 22,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final dy = math.sin(t * math.pi * 2) * (7 * widget.intensity);
            final scale = 0.95 + ((math.sin((t + 0.15) * math.pi * 2) + 1) * 0.03 * widget.intensity);
            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: 0.36 * widget.intensity,
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
