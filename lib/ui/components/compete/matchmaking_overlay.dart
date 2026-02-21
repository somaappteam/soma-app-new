// lib/ui/components/compete/matchmaking_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../common/panel_card.dart';
import '../common/primary_button.dart';

/// UI-only matchmaking overlay:
/// - Searching state with animated dots
/// - Found state
/// - Countdown 3..2..1..GO
///
/// Usage:
/// MatchmakingOverlay(
///   visible: true,
///   courseLabel: "English → Japanese",
///   onCancel: ...,
///   onFinished: ...,
/// )
class MatchmakingOverlay extends StatefulWidget {
  const MatchmakingOverlay({
    super.key,
    required this.visible,
    required this.courseLabel,
    required this.onCancel,
    required this.onFinished,
  });

  final bool visible;
  final String courseLabel;
  final VoidCallback onCancel;
  final VoidCallback onFinished;

  @override
  State<MatchmakingOverlay> createState() => _MatchmakingOverlayState();
}

enum _Stage { searching, found, countdown, done }

class _MatchmakingOverlayState extends State<MatchmakingOverlay> {
  _Stage _stage = _Stage.searching;
  int _countdown = 3;

  Timer? _timer;
  Timer? _dotTimer;
  int _dots = 0;

  @override
  void didUpdateWidget(covariant MatchmakingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.visible && widget.visible) {
      _startFlow();
    }
    if (oldWidget.visible && !widget.visible) {
      _stopTimers();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.visible) _startFlow();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  void _stopTimers() {
    _timer?.cancel();
    _dotTimer?.cancel();
    _timer = null;
    _dotTimer = null;
  }

  void _startFlow() {
    _stopTimers();
    setState(() {
      _stage = _Stage.searching;
      _countdown = 3;
      _dots = 0;
    });

    // animated dots
    _dotTimer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (!mounted) return;
      setState(() => _dots = (_dots + 1) % 4);
    });

    // searching → found
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _stage = _Stage.found);

      // found → countdown
      _timer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _stage = _Stage.countdown);

        // countdown 3..2..1..GO
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted) return;
          if (_countdown > 1) {
            setState(() => _countdown -= 1);
          } else {
            t.cancel();
            setState(() => _stage = _Stage.done);
            _stopTimers();
            widget.onFinished();
          }
        });
      });
    });
  }

  String get _dotText => '.' * _dots;

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Material(
        color: AppColors.overlay,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Center(
              child: PanelCard(
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildStage(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStage(BuildContext context) {
    switch (_stage) {
      case _Stage.searching:
        return Column(
          key: const ValueKey('searching'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_tethering_rounded,
              size: 44,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text('Finding opponent$_dotText', style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.s8),
            Text(widget.courseLabel, style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.s16),
            PrimaryButton(
              label: 'Cancel',
              onTap: () {
                _stopTimers();
                widget.onCancel();
              },
              color: AppColors.panel,
              pressedColor: AppColors.panel2,
              icon: Icons.close_rounded,
            ),
          ],
        );

      case _Stage.found:
        return Column(
          key: const ValueKey('found'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 44,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text('Opponent found!', style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.s8),
            Text('Get ready…', style: AppTextStyles.bodyMuted),
          ],
        );

      case _Stage.countdown:
        return Column(
          key: const ValueKey('countdown'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Starting in', style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.s8),
            Text('$_countdown', style: AppTextStyles.numberBig),
            const SizedBox(height: AppSpacing.s8),
            Text('Answer fast!', style: AppTextStyles.small),
          ],
        );

      case _Stage.done:
        return const SizedBox(key: ValueKey('done'));
    }
  }
}
