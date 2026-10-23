import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.repository});

  final OnboardingRepository repository;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.map_outlined,
      title: 'See city heat clearly',
      description: 'Explore predicted land surface temperature across Kota Malang from satellite data.',
    ),
    _OnboardingPageData(
      icon: Icons.local_fire_department_outlined,
      title: 'Find potential hotspots',
      description: 'Spot areas with higher heat and understand which factors contribute to it.',
    ),
    _OnboardingPageData(
      icon: Icons.eco_outlined,
      title: 'Explore cooling ideas',
      description: 'Review suggested mitigation measures such as greening and cool surfaces.',
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  Future<void> _finish() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    await widget.repository.markOnboardingSeen();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _continue() async {
    if (_currentPage == _pages.length - 1) {
      await _finish();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              SizedBox(
                height: AppSpacing.xl + AppSpacing.xs,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _currentPage == _pages.length - 1
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: _isFinishing ? null : _finish,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            textStyle: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Skip'),
                        ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      _OnboardingPage(page: _pages[index]),
                ),
              ),
              _PageIndicator(count: _pages.length, activeIndex: _currentPage),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.xl + AppSpacing.lg,
                child: ElevatedButton(
                  onPressed: _isFinishing ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.surface,
                    disabledBackgroundColor: AppColors.accent,
                    disabledForegroundColor: AppColors.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedSm,
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get started' : 'Next',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final _OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.xl * 3 + AppSpacing.sm * 2,
              height: AppSpacing.xl * 3 + AppSpacing.sm * 2,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xl),
              ),
              child: Icon(
                page.icon,
                size: AppSpacing.lg * 2,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.pageTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: AppSpacing.screenPaddingH,
              child: Text(
                page.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isActive ? AppSpacing.lg : AppSpacing.xs,
          height: AppSpacing.xs,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : AppColors.border,
            borderRadius: AppSpacing.roundedFull,
          ),
        );
      }),
    );
  }
}
