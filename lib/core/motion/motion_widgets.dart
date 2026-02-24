import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/radii.dart';
import '../theme/text_styles.dart';
import 'motion.dart';

class SquishyButton extends StatefulWidget {
  const SquishyButton({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.scaleDown = AppMotion.pressScale,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double scaleDown;

  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? widget.onTap : null,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1,
        duration: _pressed ? AppMotion.tapDown : AppMotion.tapUp,
        curve: _pressed ? AppMotion.microCurve : AppMotion.bounceOut,
        child: AnimatedSlide(
          duration: _pressed ? AppMotion.tapDown : AppMotion.tapUp,
          curve: AppMotion.smooth,
          offset: Offset(0, _pressed ? 0.01 : 0),
          child: widget.child,
        ),
      ),
    );
  }
}

class BouncyIcon extends StatefulWidget {
  const BouncyIcon({
    super.key,
    required this.icon,
    this.size = 22,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  State<BouncyIcon> createState() => _BouncyIconState();
}

class _BouncyIconState extends State<BouncyIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.micro,
  )..forward();

  late final Animation<double> _scale = Tween<double>(begin: 0.86, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: AppMotion.bounceOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(widget.icon, size: widget.size, color: widget.color),
    );
  }
}

class ElasticPanel extends StatelessWidget {
  const ElasticPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return PopIn(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: AppRadii.br16,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: child,
      ),
    );
  }
}

class Wiggle extends StatefulWidget {
  const Wiggle({super.key, required this.child, this.enabled = true, this.amplitude = 0.024});

  final Widget child;
  final bool enabled;
  final double amplitude;

  @override
  State<Wiggle> createState() => _WiggleState();
}

class _WiggleState extends State<Wiggle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final radians = math.sin(t * math.pi * 2) * widget.amplitude;
        return Transform.rotate(angle: radians, child: child);
      },
    );
  }
}

class PopIn extends StatefulWidget {
  const PopIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.page,
  );

  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: AppMotion.enter);
  late final Animation<double> _scale = Tween<double>(begin: 0.94, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: AppMotion.bounceOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class Float extends StatefulWidget {
  const Float({super.key, required this.child, this.distance = 8});

  final Widget child;
  final double distance;

  @override
  State<Float> createState() => _FloatState();
}

class _FloatState extends State<Float> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = math.sin(_controller.value * math.pi * 2);
        final dy = value * widget.distance;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.from,
    required this.to,
    this.duration = const Duration(milliseconds: 800),
    this.curve = AppMotion.microCurve,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  final int from;
  final int to;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: from.toDouble(), end: to.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, value, _) => Text(
        '$prefix${value.round()}$suffix',
        style: style ?? AppTextStyles.subtitle,
      ),
    );
  }
}

class AnimatedProgress extends StatefulWidget {
  const AnimatedProgress({
    super.key,
    required this.value,
    this.duration = AppMotion.micro,
    required this.builder,
  });

  final double value;
  final Duration duration;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<AnimatedProgress> createState() => _AnimatedProgressState();
}

class _AnimatedProgressState extends State<AnimatedProgress> {
  double _from = 0;

  @override
  void initState() {
    super.initState();
    _from = widget.value.clamp(0, 1);
  }

  @override
  void didUpdateWidget(covariant AnimatedProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _from = oldWidget.value.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.value.clamp(0, 1);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _from, end: target),
      duration: widget.duration,
      curve: AppMotion.smooth,
      builder: (context, animatedValue, _) => widget.builder(context, animatedValue),
    );
  }
}
