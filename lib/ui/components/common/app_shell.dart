import 'package:flutter/material.dart';

/// Reusable scene wrapper that keeps layout/safe-area consistent while
/// letting the persistent world render behind screens.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.body, this.hud, this.bottom});

  final Widget body;
  final Widget? hud;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            if (hud != null) hud!,
            Expanded(child: body),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}
