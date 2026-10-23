import '../../../../core/failures.dart';

typedef OnboardingResult<T> = ({T? data, Failure? failure});

abstract interface class OnboardingRepository {
  Future<OnboardingResult<bool>> hasSeenOnboarding();

  Future<OnboardingResult<bool>> markOnboardingSeen();
}
