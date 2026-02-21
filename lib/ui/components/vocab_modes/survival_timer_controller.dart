import 'dart:async';
import 'package:flutter/foundation.dart';

/// Controller for the Survival Timer vocab mode.
class SurvivalTimerController extends ChangeNotifier {
  SurvivalTimerController({
    required this.onTimerComplete,
    this.initialTimeMs = 30000,
    this.bonusMs = 3000,
    this.penaltyMs = 5000,
  });

  final VoidCallback onTimerComplete;
  final int initialTimeMs;
  final int bonusMs;
  final int penaltyMs;

  late int _timeRemainingMs;
  int get timeRemainingMs => _timeRemainingMs;

  int _survivedSeconds = 0;
  int get survivedSeconds => _survivedSeconds;

  int? _lastPenaltyMs;
  int? get lastPenaltyMs => _lastPenaltyMs;

  int? _lastBonusMs;
  int? get lastBonusMs => _lastBonusMs;

  Timer? _ticker;
  DateTime? _lastTickAt;
  DateTime? _startTime;

  void start() {
    _timeRemainingMs = initialTimeMs;
    _survivedSeconds = 0;
    _lastPenaltyMs = null;
    _lastBonusMs = null;
    
    _startTime = DateTime.now();
    _lastTickAt = DateTime.now();
    
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), _tick);
    
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_lastTickAt == null) return;
    
    final now = DateTime.now();
    final delta = now.difference(_lastTickAt!).inMilliseconds;
    _lastTickAt = now;
    
    _timeRemainingMs -= delta;
    
    if (_startTime != null) {
      _survivedSeconds = now.difference(_startTime!).inSeconds;
    }
    
    if (_timeRemainingMs <= 0) {
      _timeRemainingMs = 0;
      stop();
      onTimerComplete();
    }
    
    notifyListeners();
  }

  void markCorrect() {
    _timeRemainingMs += bonusMs;
    _lastBonusMs = bonusMs;
    _lastPenaltyMs = null;
    notifyListeners();
  }

  void markWrong() {
    _timeRemainingMs -= penaltyMs;
    _lastPenaltyMs = penaltyMs;
    _lastBonusMs = null;
    if (_timeRemainingMs < 0) _timeRemainingMs = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
