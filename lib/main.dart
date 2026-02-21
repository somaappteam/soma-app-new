// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://inbeuxvhgqisnjeztlio.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImluYmV1eHZoZ3Fpc25qZXp0bGlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2ODI0OTEsImV4cCI6MjA4NzI1ODQ5MX0.b1pTk4WAHIA2zRIy3I6VYZ1k2n0t5APUqaIdN7D4Zuo',
  );

  runApp(const App());
}
