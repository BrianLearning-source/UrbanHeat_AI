
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/onboarding_repository.dart';
import '../widgets/onboarding_map_preview.dart';
import '../widgets/onboarding_challenge_visual.dart';
import '../widgets/onboarding_data_visual.dart';
import '../widgets/onboarding_insights_visual.dart';
import '../widgets/onboarding_final_visual.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.repository,
  });

  final OnboardingRepository repository;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color _background = Color(0xFF06132B);
  static const Color _cyan = Color(0xFF33C1EA);
  static const Color _muted = Color(0xFFA8C1E2);
  static const Color _white = Colors.white;

  static const List<_SlideData> _slides = [
    _SlideData(
      category: 'URBAN HEAT INTELLIGENCE',
      title: 'Understand urban heat.\nSee your city differently.',
      description:
          'Explore AI-powered heat insights for Kecamatan Lowokwaru, Malang.',
    ),
    _SlideData(
      category: 'HOTSPOT DETECTION',
      title: 'Discover where\nheat concentrates.',
      description:
          'Identify areas with higher land surface temperatures and explore potential urban heat hotspots.',
    ),
    _SlideData(
      category: 'SATELLITE INSIGHTS',
      title: 'Understand the\nworld through data.',
      description:
          'Explore environmental indicators derived from satellite observations to understand urban conditions.',
    ),
    _SlideData(
      category: 'AI-POWERED ANALYSIS',
      title: 'Look beyond\ntoday’s temperature.',
      description:
          'Explore machine learning-based temperature predictions and discover potential future heat patterns.',
    ),
    _SlideData(
      category: 'URBAN COOLING INSIGHTS',
      title: 'Make cities\ncooler together.',
      description:
          'Discover potential mitigation strategies and insights that support a more comfortable urban environment.',
    ),
  ];

  final PageController _pageController = PageController();

  int _currentPage = 0;
  int _slideAnimationVersion = 0;
  bool _isFinishing = false;

  bool get _isLightPage => _currentPage >= 1 && _currentPage <= 3;

  Future<void> _finish() async {
    if (_isFinishing) return;

    setState(() {
      _isFinishing = true;
    });

    try {
      await widget.repository.markOnboardingSeen();

      if (!mounted) return;
      context.go('/login');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isFinishing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to continue. Please try again.'),
        ),
      );
    }
  }

  Future<void> _continue() async {
    if (_isFinishing) return;

    if (_currentPage == _slides.length - 1) {
      await _finish();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
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
      backgroundColor:
          _isLightPage ? const Color(0xFFF6F9FF) : _background,

      // Entrance animation after splash screen.
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 8,
            ),
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,

                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _slideAnimationVersion++;
                      });
                    },

                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(
                          'slide-$index-$_slideAnimationVersion',
                        ),
                        tween: Tween<double>(
                          begin: 0,
                          end: 1,
                        ),
                        duration: const Duration(milliseconds: 550),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                18 * (1 - value),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: _buildSlide(_slides[index], index),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                _buildIndicator(),

                if (_currentPage != 4) ...[
                  const SizedBox(height: 24),
                  _buildBottomNavigation(),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    final isLight = _isLightPage;

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Text(
            'URBANHEAT AI',
            style: TextStyle(
              color: isLight ? const Color(0xFF06132B) : _white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),

          const Spacer(),

          Text(
            '${(_currentPage + 1).toString().padLeft(2, '0')}'
            '  /  '
            '${_slides.length.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isLight ? const Color(0xFF566D8C) : _muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(width: 12),

          if (_currentPage != _slides.length - 1)
            TextButton(
              onPressed: _isFinishing ? null : _finish,
              style: TextButton.styleFrom(
                foregroundColor:
                    isLight ? const Color(0xFF566D8C) : _muted,
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 36),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // SLIDE CONTENT
  Widget _buildSlide(_SlideData slide, int index) {
    switch (index) {
      case 1:
        return const SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: OnboardingChallengeVisual(),
        );

      case 2:
        return const SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: OnboardingDataVisual(),
        );

      case 3:
        return const SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: OnboardingInsightsVisual(),
        );

      case 4:
        return const SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: OnboardingFinalVisual(),
        );

      // SLIDE 1
      default:
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Section label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF193A5E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        slide.category,
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Headline
                    Text(
                      slide.title,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 29,
                        height: 1.17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      slide.description,
                      style: const TextStyle(
                        color: Color(0xFFC9DBF2),
                        fontSize: 12,
                        height: 1.65,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // MAP PREVIEW - SLIDE 1
                    const OnboardingMapPreview(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
    }
  }

  // PAGE INDICATOR
  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) {
          final active = index == _currentPage;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: active ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: active ? _cyan : const Color(0xFF526B88),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _buildBottomNavigation() {
    final isLight = _isLightPage;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isFinishing ? null : _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: _cyan,
              foregroundColor: _background,
              disabledBackgroundColor: _cyan.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isFinishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _background,
                    ),
                  )
                : Text(
                    'Continue',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 13),

        Text(
          'Explore the product before signing in.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isLight ? const Color(0xFF566D8C) : _muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// SLIDE DATA
class _SlideData {
  const _SlideData({
    required this.category,
    required this.title,
    required this.description,
  });

  final String category;
  final String title;
  final String description;
}