import 'dart:typed_data';

import '../../../../core/failures.dart';
import '../entities/user_profile.dart';

typedef ProfileResult = ({UserProfile? data, Failure? failure});

abstract interface class ProfileRepository {
  ProfileResult getProfile(); //ini ngambil profil pengguna yang login

  Stream<UserProfile?> watchProfile(); //bagian ini mendengar perubahan data profil pengugna

  Future<ProfileResult> updateProfile({required String name, Uint8List? avatarBytes, String? avatarExtension, bool removeAvatar = false,}); 


}
