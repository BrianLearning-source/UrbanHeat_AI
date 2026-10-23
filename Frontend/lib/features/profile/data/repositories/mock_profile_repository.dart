import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

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
}
