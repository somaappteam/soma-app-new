import 'package:flutter/material.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/text_styles.dart';
import '../components/common/app_shell.dart';
import '../components/common/primary_button.dart';
import '../components/common/panel_card.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  String? _selectedLanguage;
  String? _selectedLevel;

  final List<String> _languages = const [
    'Spanish', 'French', 'Japanese', 'German', 'Korean', 'Italian', 'Portuguese'
  ];

  final List<String> _levels = const [
    'Beginner', 'Intermediate', 'Advanced',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      // Finish onboarding
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }

  bool _canProceed() {
    if (_currentIndex == 0) return true;
    if (_currentIndex == 1) return _selectedLanguage != null;
    if (_currentIndex == 2) return _selectedLevel != null;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s16),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      decoration: BoxDecoration(
                        color: index <= _currentIndex ? AppColors.primary : AppColors.panelBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  _buildWelcomeStep(),
                  _buildLanguageStep(),
                  _buildLevelStep(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _canProceed() ? 1.0 : 0.5,
                child: PrimaryButton(
                  label: _currentIndex == 2 ? 'Start Learning' : 'Continue',
                  icon: _currentIndex == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                  onTap: _canProceed() ? _nextPage : () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.public_rounded,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.s32),
          Text(
            'Ready to master a new language?',
            style: AppTextStyles.title.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Bite-sized lessons, real-world context, and smart progression.',
            style: AppTextStyles.bodyMuted.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s24),
          Text('I want to learn...', style: AppTextStyles.title.copyWith(fontSize: 28)),
          const SizedBox(height: AppSpacing.s24),
          Expanded(
            child: ListView.separated(
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = _selectedLanguage == lang;
                return _SelectableCard(
                  label: lang,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedLanguage = lang),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s24),
          Text('My current level is...', style: AppTextStyles.title.copyWith(fontSize: 28)),
          const SizedBox(height: AppSpacing.s24),
          Expanded(
            child: ListView.separated(
              itemCount: _levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final level = _levels[index];
                final isSelected = _selectedLevel == level;
                return _SelectableCard(
                  label: level,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedLevel = level);
                    // UX improvement: auto-advance on the last step selection 
                    // to reduce friction, but wait a tiny bit to show selection
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) _nextPage();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.panelBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.subtitle.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
