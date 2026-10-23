import '../../../../core/failures.dart';
import '../entities/user_profile.dart';

typedef ProfileResult = ({UserProfile? data, Failure? failure});

abstract interface class ProfileRepository {
  ProfileResult getProfile();
}
