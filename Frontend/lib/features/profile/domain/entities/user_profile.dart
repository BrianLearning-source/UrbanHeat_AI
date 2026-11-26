/// A business representation of the current user's profile.
class UserProfile {
  const UserProfile({
    this.id,
    required this.name,
    required this.role,
    required this.location,
    this.avatarUrl,
  });

  final String? id;
  final String name;
  final String? avatarUrl;
  final String role;
  final String location;
}
