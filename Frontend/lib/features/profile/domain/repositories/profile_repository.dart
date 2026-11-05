import '../../../../core/failures.dart';
import '../entities/user_profile.dart';

typedef ProfileResult = ({UserProfile? data, Failure? failure});

abstract interface class ProfileRepository {
  ProfileResult getProfile(); //ini ngambil profil pengguna yang login

  Stream<UserProfile?> watchProfile(); //bagian ini mendengar perubahan data profil pengugna

  Future<ProfileResult> updateProfile({required String name,}); //kalau yang ini memperbarui data profil pengguna
}
