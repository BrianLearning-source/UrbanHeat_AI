/// A business representation of the current user's profile.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.role,
    required this.location,
  });

  final String name;
  final String role;
  final String location;
}
