// lib/core/routing/transitions.dart
import 'package:flutter/material.dart';
import '../motion/motion.dart';

/// Unity-like page transitions: fade + slight scale + tiny slide up.
/// Use this for ALL page navigation to keep the app feeling consistent.
class AppTransitions {
  static PageRoute<T> sceneRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: AppMotion.page,
      reverseTransitionDuration: AppMotion.page,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.enter,
        );

        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
        final scale = Tween<double>(
          begin: AppMotion.enterScaleFrom,
          end: 1.0,
        ).animate(curved);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.02), // ~ small upward motion
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );
  }
}
