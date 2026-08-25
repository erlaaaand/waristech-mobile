import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';

/// Kontrak domain untuk autentikasi.
/// Presentation layer hanya bergantung pada abstrak ini, bukan implementasi.
abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
}
