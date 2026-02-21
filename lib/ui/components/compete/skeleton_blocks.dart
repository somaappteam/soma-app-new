// lib/ui/components/compete/skeleton_blocks.dart
import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';
import '../common/panel_card.dart';
import '../common/shimmer_skeleton.dart';

class OpponentSkeleton extends StatelessWidget {
  const OpponentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        ShimmerSkeleton(width: 28, height: 28, shape: BoxShape.circle),
        SizedBox(width: 10),
        ShimmerSkeleton(width: 80, height: 14),
      ],
    );
  }
}

class QuestionCardSkeleton extends StatelessWidget {
  const QuestionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerSkeleton(width: 120, height: 14),
          SizedBox(height: AppSpacing.s12),
          ShimmerSkeleton(width: double.infinity, height: 24),
          SizedBox(height: AppSpacing.s8),
          ShimmerSkeleton(width: 220, height: 24),
          SizedBox(height: AppSpacing.s16),
          Divider(color: AppColors.panelBorder),
          SizedBox(height: AppSpacing.s12),
          ShimmerSkeleton(width: double.infinity, height: 48),
        ],
      ),
    );
  }
}
