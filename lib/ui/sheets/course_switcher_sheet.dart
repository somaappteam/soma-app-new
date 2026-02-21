// lib/ui/sheets/course_switcher_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';

/// UI-only course switcher sheet.
/// Later you will connect this to AppController (courses list).
class CourseSwitcherSheet extends StatelessWidget {
  const CourseSwitcherSheet({
    super.key,
    required this.activeCourse,
    required this.courses,
    required this.onSelectCourse,
    required this.onAddCourse,
  });

  final String activeCourse; // e.g. "English → Japanese"
  final List<String> courses; // list of course strings
  final ValueChanged<String> onSelectCourse;
  final VoidCallback onAddCourse;

  static Future<void> show(
    BuildContext context, {
    required String activeCourse,
    required List<String> courses,
    required ValueChanged<String> onSelectCourse,
    required VoidCallback onAddCourse,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CourseSwitcherSheet(
        activeCourse: activeCourse,
        courses: courses,
        onSelectCourse: onSelectCourse,
        onAddCourse: onAddCourse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s16,
        top: AppSpacing.s16,
      ),
      child: PanelCard(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Courses', style: AppTextStyles.subtitle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),

            Text('My courses', style: AppTextStyles.small),
            const SizedBox(height: AppSpacing.s8),

            ...courses.map((c) {
              final isActive = c == activeCourse;
              return _CourseRow(
                title: c,
                active: isActive,
                onTap: () {
                  onSelectCourse(c);
                  Navigator.pop(context);
                },
              );
            }),

            const SizedBox(height: AppSpacing.s16),

            PrimaryButton(
              label: '+ Add new course',
              onTap: () {
                Navigator.pop(context);
                onAddCourse();
              },
              color: AppColors.secondary,
              pressedColor: AppColors.secondaryPressed,
              icon: Icons.add_rounded,
            ),

            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.title,
    required this.active,
    required this.onTap,
  });

  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            Icon(
              active ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: active ? AppColors.success : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: active ? AppTextStyles.body : AppTextStyles.bodyMuted,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
