import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';

/// Kontrak repository autentikasi.
abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity?> getMe();
  Future<void> logout();
}
