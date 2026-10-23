import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/repositories/onboarding_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.repository});

  final OnboardingRepository repository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_routeAfterSplash());
  }

  Future<void> _routeAfterSplash() async {
    final onboardingSeen = widget.repository.hasSeenOnboarding();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final result = await onboardingSeen;
    if (!mounted) return;

    // TODO: once backend/auth exists, send users with a valid session to Home.
    context.go(result.data == true ? '/login' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.scale(scale: value, child: child),
          ),
          child: SvgPicture.asset(
            'assets/branding/urbanheat_logo.svg',
            width: AppSpacing.xl * 3,
            height: AppSpacing.xl * 3,
            semanticsLabel: 'UrbanHeat AI logo',
          ),
        ),
      ),
    );
  }
}
