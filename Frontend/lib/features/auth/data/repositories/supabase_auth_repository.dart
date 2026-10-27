import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

// Mengoneksikan kontrak autentikasi Domain Layer ke autentikasi supabase
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  // Mengambil user dari Supabase menjadi AppUser aplikasi UrbanHeat.
  AppUser? _mapUser(User? user) {
    if (user == null) return null;

    return AppUser(id: user.id, email: user.email ?? '');
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
      data: {'full_name': fullName.trim()},
    );

    // A user returned without a session has not signed in yet.
    return response.session == null ? null : _mapUser(response.session!.user);
  }

  @override
  // Mengecek kredensial lalu masuk ke akun pengguna
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final session = response.session;
    if (session == null) {
      throw const AuthException(
        'Sign in did not return an active session. Please try again.',
      );
    }

    final user = _mapUser(session.user);
    if (user == null) {
      throw const AuthException(
        'Pengguna tidak ditemukan. Tolong periksa kembali.',
      );
    }

    return user;
  }

  @override
  // Mengambil pengguna dari sesi yang lagi aktif.
  Future<AppUser?> getCurrentUser() async {
    return _mapUser(_supabase.auth.currentSession?.user);
  }

  @override
  // Mengakhiri sesi autentikasi pengguna di Supabase.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  // Map perubahan sesi ke entity aplikasi, tanpa mengekspos tipe Supabase.
  Stream<AppUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map(
      (event) => _mapUser(event.session?.user),
    );
  }
}
