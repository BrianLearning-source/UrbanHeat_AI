import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPreferences {
  const OnboardingPreferences._();

  static const String _onboardingSeenKey = 'onboarding_seen';

  static Future<bool> hasSeenOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingSeenKey, true);
  }
}
