import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'dart:typed_data';

import '../../../../core/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._supabase);

  // Client Supabase yang sudah diinisialisasi di main.dart.
  final SupabaseClient _supabase;

  // Nama bucket Supabase buat nyimpan foto profil
  static const String _avatarBucket = 'avatars';

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
        return (data: null, failure: const UnexpectedFailure());
      }

      return (data: profile, failure: null);
    } catch (_) {
      return (data: null, failure: const UnexpectedFailure());
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
  Future<ProfileResult> updateProfile({
    required String name,
    Uint8List? avatarBytes,
    String? avatarExtension,
    bool removeAvatar = false,
  }) async {
    try {
      // Memastikan pengguna sudah login.
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        return (data: null, failure: const UnexpectedFailure());
      }

      // URL foto lama dipertahankan jika pengguna tidak mengganti foto.
      String? avatarUrl = currentUser.userMetadata?['avatar_url'] as String?;

      // Tidak boleh mengunggah dan menghapus foto sekaligus.
      if (removeAvatar && avatarBytes != null) {
        return (data: null, failure: const UnexpectedFailure());
      }

      // Proses upload jika pengguna memilih foto baru.
      if (avatarBytes != null) {
        final extension = avatarExtension?.toLowerCase();

        // Membatasi format gambar yang dapat diunggah.
        const allowedExtensions = ['jpg', 'jpeg', 'png'];

        if (extension == null || !allowedExtensions.contains(extension)) {
          return (data: null, failure: const UnexpectedFailure());
        }

        // Menentukan content type berdasarkan ekstensi gambar.
        final contentType = switch (extension) {
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          _ => 'application/octet-stream',
        };

        // Nama file unik agar foto lama tidak tertahan cache.
        final fileName =
            'avatar_${DateTime.now().microsecondsSinceEpoch}.$extension';

        // Setiap pengguna menyimpan foto di folder berdasarkan user ID.
        final storagePath = '${currentUser.id}/$fileName';

        // Mengunggah bytes gambar ke Supabase Storage.
        await _supabase.storage
            .from(_avatarBucket)
            .uploadBinary(
              storagePath,
              avatarBytes,
              fileOptions: FileOptions(contentType: contentType, upsert: false),
            );

        // Mengambil URL publik dari file yang berhasil diunggah.
        avatarUrl = _supabase.storage
            .from(_avatarBucket)
            .getPublicUrl(storagePath);
      }

      // Jika pengguna menghapus foto, kosongkan URL-nya.
      if (removeAvatar) {
        avatarUrl = null;
      }

      // Memperbarui nama dan URL foto pada metadata Supabase Auth.
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': name.trim(), 'avatar_url': avatarUrl},
        ),
      );

      // Mengubah hasil update Supabase menjadi entity aplikasi.
      final updatedProfile = _mapUser(response.user);

      if (updatedProfile == null) {
        return (data: null, failure: const UnexpectedFailure());
      }

      return (data: updatedProfile, failure: null);
    } catch (error, stackTrace) {
      debugPrint('SupabaseProfileRepository.updateProfile failed: $error');
      debugPrint('$stackTrace');
      return (data: null, failure: const UnexpectedFailure());
    }
  }
}
