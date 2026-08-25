import 'package:wt_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:wt_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:wt_mobile/core/network/dio_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final json = await _dataSource.login(email, password);
    return UserEntity.fromBackendJson(json);
  }

  @override
  Future<UserEntity?> getMe() async {
    try {
      final json = await _dataSource.getMe();
      // GET /auth/me mengembalikan { userId, email, role, ... }
      // Normalisasi ke format yang bisa diproses fromBackendJson
      final normalized = {
        'user': {
          'id': json['userId'] ?? json['id'] ?? json['sub'] ?? '',
          'email': json['email'] ?? '',
          'fullName': json['fullName'] ?? json['name'] ?? '',
          'role': json['role'] ?? '',
          'avatarUrl': json['avatarUrl'],
        }
      };
      return UserEntity.fromBackendJson(normalized);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
    await DioClient().clearSession();
  }
}
