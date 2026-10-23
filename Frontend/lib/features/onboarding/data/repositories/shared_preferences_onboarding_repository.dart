import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';

class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  const SharedPreferencesOnboardingRepository();

  static const String _onboardingSeenKey = 'onboarding_seen';

  @override
  Future<OnboardingResult<bool>> hasSeenOnboarding() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return (
        data: preferences.getBool(_onboardingSeenKey) ?? false,
        failure: null,
      );
    } catch (_) {
      return (data: null, failure: const LocalFailure());
    }
  }

  @override
  Future<OnboardingResult<bool>> markOnboardingSeen() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = await preferences.setBool(_onboardingSeenKey, true);
      return stored
          ? (data: true, failure: null)
          : (data: null, failure: const LocalFailure());
    } catch (_) {
      return (data: null, failure: const LocalFailure());
    }
  }
}
