import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._supabase);

  // Client Supabase yang sudah diinisialisasi di main.dart.
  final SupabaseClient _supabase;

  // Mengubah data Supabase Auth menjadi entity UserProfile.
  UserProfile? _mapUser(User? user) {
    if (user == null) return null;

    final metadata = user.userMetadata ?? {};

    // Mengambil nama dari metadata ketika registrasi.
    final fullName = metadata['full_name'] as String?;

    // Mengambil URL foto profil dari metadata.
    final avatarUrl = metadata['avatar_url'] as String?;

    return UserProfile(
      id: user.id,
      name: fullName?.trim().isNotEmpty == true
          ? fullName!.trim()
          : (user.email?.split('@').first ?? 'User'),
      avatarUrl: avatarUrl,
      role: 'Urban Researcher',
      location: 'Kota Malang, East Java',
    );
  }

  @override
  ProfileResult getProfile() {
    try {
      final profile = _mapUser(_supabase.auth.currentUser);

      if (profile == null) {
        return (
          data: null,
          failure: const UnexpectedFailure(),
        );
      }

      return (
        data: profile,
        failure: null,
      );
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(),
      );
    }
  }

  @override
  Stream<UserProfile?> watchProfile() async* {
    // Kirim profil pengguna yang sedang aktif terlebih dahulu.
    yield _mapUser(_supabase.auth.currentUser);

    // Kemudian dengarkan perubahan autentikasi dan metadata.
    yield* _supabase.auth.onAuthStateChange.map(
      (event) => _mapUser(event.session?.user),
    );
  }

  @override
  Future<ProfileResult> updateProfile({required String name,}) async {
    try {
      final response = await _supabase.auth.updateUser(UserAttributes(
        data: {
          'full_name' : name.trim(),
        },
      ),
      );

      final updatedProfile = _mapUser(response.user);

      if (updatedProfile == null) {
        return (
          data: null,
          failure: const UnexpectedFailure(),
        );
      } 

      return (
        data: updatedProfile,
        failure: null,
      );
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(),
      );
    }
  }
}