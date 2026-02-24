import 'package:flutter/material.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'ui/components/world/persistent_world.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Duel',
      theme: AppTheme.dark(),
      home: const _WorldNavigatorHost(),
    );
  }
}

class _WorldNavigatorHost extends StatelessWidget {
  const _WorldNavigatorHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PersistentWorld(),
          Navigator(
            initialRoute: AppRouter.setup,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ],
      ),
    );
  }
}
