// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'transitions.dart';

// Screens (we’ll create these files later in order)
import '../../ui/screens/setup_page.dart';
import '../../ui/screens/home_page.dart';
import '../../ui/screens/player_page.dart';
import '../../ui/screens/result_page.dart';

/// Simple Navigator 1.0 router (keeps things easy).
/// All routes use the same Unity-like transition.
class AppRouter {
  static const String setup = '/setup';
  static const String home = '/home';
  static const String player = '/player';
  static const String result = '/result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case setup:
        return AppTransitions.sceneRoute(
          page: const SetupPage(),
          settings: settings,
        );

      case home:
        return AppTransitions.sceneRoute(
          page: const HomePage(),
          settings: settings,
        );

      case player:
        // args: PlayerArgs(mode: solo/compete, sessionId optional)
        final args = settings.arguments as PlayerArgs?;
        return AppTransitions.sceneRoute(
          page: PlayerPage(args: args ?? const PlayerArgs.solo()),
          settings: settings,
        );

      case result:
        // args: ResultArgs(...)
        final args = settings.arguments as ResultArgs?;
        return AppTransitions.sceneRoute(
          page: ResultPage(args: args ?? ResultArgs.empty()),
          settings: settings,
        );

      default:
        return AppTransitions.sceneRoute(
          page: const SetupPage(),
          settings: settings,
        );
    }
  }
}
