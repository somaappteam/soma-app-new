import 'package:flutter/foundation.dart';
import '../ui/components/vocab_modes/vocab_mode_type.dart';
import '../ui/components/sentence_modes/sentence_mode_type.dart';

/// UI-only global state for now.
/// Later you can connect this to local storage + backend.
class AppController extends ChangeNotifier {
  // Course (base -> target)
  String baseLang = 'English';
  String targetLang = 'Japanese';

  // Multiple courses (stored as "Base → Target" strings for UI demo)
  final List<String> courses = [
    'English → Japanese',
    'English → French',
    'Portuguese → English',
  ];

  // Stats
  int xp = 1200;
  int streak = 5;

  // Settings
  bool soundOn = true;
  bool hapticsOn = true;

  // Active Vocab Mode (UI-only for now)
  VocabGameMode vocabMode = VocabGameMode.classicMcq;

  // Sentence game mode (UI-only for now)
  SentenceGameMode sentenceMode = SentenceGameMode.classicFill;

  // Login (UI-only)
  bool isLoggedIn = false;
  String displayName = 'Guest';

  String get activeCourseLabel => '$baseLang → $targetLang';

  void selectCourseLabel(String label) {
    // label format: "Base → Target"
    final parts = label.split('→');
    if (parts.length == 2) {
      baseLang = parts[0].trim();
      targetLang = parts[1].trim();
      notifyListeners();
    }
  }

  void addCourse(String base, String target) {
    final label = '$base → $target';
    if (!courses.contains(label)) {
      courses.add(label);
    }
    baseLang = base;
    targetLang = target;
    notifyListeners();
  }

  void setSound(bool v) {
    soundOn = v;
    notifyListeners();
  }

  void setHaptics(bool v) {
    hapticsOn = v;
    notifyListeners();
  }

  // Demo helpers: simulate earning XP / streak update
  void addXp(int amount) {
    xp += amount;
    notifyListeners();
  }

  void incrementStreak() {
    streak += 1;
    notifyListeners();
  }

  void signInAs(String name) {
    isLoggedIn = true;
    displayName = name;
    notifyListeners();
  }

  void signOut() {
    isLoggedIn = false;
    displayName = 'Guest';
    notifyListeners();
  }

  void setVocabMode(VocabGameMode mode) {
    vocabMode = mode;
    notifyListeners();
  }

  void setSentenceMode(SentenceGameMode mode) {
    sentenceMode = mode;
    notifyListeners();
  }
}
