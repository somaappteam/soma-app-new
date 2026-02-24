import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AppController _app = AppController();
  bool _showProfile = false;

  @override
  void dispose() {
    _app.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showProfile) {
      return ProfilePage(
        app: _app,
        onBack: () => setState(() => _showProfile = false),
      );
    }

    return HomePage(
      app: _app,
      onProfileTap: () => setState(() => _showProfile = true),
    );
  }
}
