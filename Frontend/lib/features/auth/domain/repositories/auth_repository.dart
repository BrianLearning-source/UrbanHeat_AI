import '../entities/app_user.dart';

// Repository untuk mendifinisikan autentikasi yang dibutuhkan aplikasi
abstract class AuthRepository {
  bool get isAuthenticated;

  Future<AppUser?> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<AppUser> signIn({required String email, required String password});

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> sendPasswordRecoveryEmail({
    required String email,
    required String redirectTo,
  });

  Future<void> updatePasswordAfterRecovery({required String newPassword});

  Future<void> signOut();

  Future<AppUser?> getCurrentUser();

  Stream<AppUser?> get authStateChanges;
}
