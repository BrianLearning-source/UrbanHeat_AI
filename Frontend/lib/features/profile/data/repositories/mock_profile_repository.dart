import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/failures.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository();

  @override
  ProfileResult getProfile() => (
    data: const UserProfile(
      name: 'Nasywa',
      role: 'Urban Researcher & Environmental Planner • Kota Malang Spatial Analysis Group',
      location: 'Kota Malang, East Java',
    ),
    failure: null,
  );

  @override
  Stream<UserProfile?> watchProfile() {
    return Stream.value(getProfile().data);
  }

  @override
  Future<ProfileResult> updateProfile({required String name}) async {
    final currentProfile = getProfile().data;

    if (currentProfile == null) {
      return (data: null, failure: const UnexpectedFailure());
    }

    return (
      data: UserProfile(
        id: currentProfile.id,
        name: name.trim(),
        avatarUrl: currentProfile.avatarUrl,
        role: currentProfile.role,
        location: currentProfile.location,
      ),
      failure: null,
    );
  }
}
