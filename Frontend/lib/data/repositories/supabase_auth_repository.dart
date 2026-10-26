import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/domain/repository/auth_repository.dart';

// Mengoneksikan kontrak autentikasi Domain Layer ke autentikasi supabase
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._supabase);

  final SupabaseClient _supabase;

  // Mengambil user dari Supabase menjadi AppUser aplikasi UrbanHeat.
  AppUser? _mapUser(User? user) {
    if (user == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  @override
  // Registrasi pengguna baru dengan email dan kata sandi
  Future<AppUser?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,

      data: {
        'full_name': fullName.trim(),
      },
    );

  // Mengubah objek User Supabase menjadi entity aplikasi
    return _mapUser(response.user);
  }

  @override
  // Mengecek kredensial lalu masuk ke akun pengguna
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(email: email.trim(), password: password,);

  // Mengubah pengguna dari Supabase menjadi AppUser
    final user = _mapUser(response.user);

  // Kalau pengguna tidak ditemukan, beri pesan error
    if (user == null) {
      throw const AuthException(
        'Pengguna tidak ditemukan. Tolong periksa kembali.',
      );
    }

    return user;
  }

  @override
  // Mengambil pengguna dari sesi yang lagi aktif
  Future<AppUser?> getCurrentUser() async {
    return _mapUser(_supabase.auth.currentUser);
  }

  @override
  // Mengakhiri sesi autentikasi pengguna di Supabase
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  // Monitoring perubahan sesi agar perubahan itu diubah jadi AppUser. Nantinya tidak bergantung ke User Supabase
  Stream<AppUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map(
      (event) => _mapUser(event.session?.user),
    );
  }

} 