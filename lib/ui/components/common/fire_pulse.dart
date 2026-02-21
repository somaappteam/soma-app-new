// lib/ui/components/common/fire_pulse.dart
import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';

/// Tiny fire icon that pulses once (great for streak saved micro celebration).
/// Use it in ResultPage near the streak row, or HUD after a session.
class FirePulse extends StatefulWidget {
  const FirePulse({super.key, this.size = 18, this.autoplay = true});

  final double size;
  final bool autoplay;

  @override
  State<FirePulse> createState() => _FirePulseState();
}

class _FirePulseState extends State<FirePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.25,
  ).animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.bounceOut));

  @override
  void initState() {
    super.initState();
    if (widget.autoplay) {
      // slight delay makes it feel intentional
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(
        Icons.local_fire_department_rounded,
        size: widget.size,
        color: AppColors.warning,
      ),
    );
  }
}
