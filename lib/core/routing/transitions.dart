import 'package:flutter/material.dart';

import '../motion/motion.dart';

class AppTransitions {
  static PageRoute<T> sceneRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: AppMotion.page,
      reverseTransitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(parent: animation, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
        final fade = Tween<double>(begin: 0, end: 1).animate(enter);
        final scale = Tween<double>(begin: AppMotion.enterScaleFrom, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        final slide = Tween<Offset>(begin: const Offset(0, 0.025), end: Offset.zero).animate(enter);
        final outgoing = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.01)).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
        );

        return SlideTransition(
          position: outgoing,
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: ScaleTransition(scale: scale, child: child)),
          ),
        );
      },
    );
  }
}
