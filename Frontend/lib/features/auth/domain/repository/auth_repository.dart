import '../entities/app_user.dart';

// Repository untuk mendifinisikan autentikasi yang dibutuhkan aplikasi
abstract class AuthRepository {
  Future<AppUser?> signUp({
    required String email,
    required String password,
  });

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<AppUser?> getCurrentUser();

  Stream<AppUser?> get authStateChanges;
}