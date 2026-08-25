import 'package:wt_mobile/core/network/dio_client.dart';
import 'package:wt_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:wt_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Implementasi konkret dari [AuthRepository].
/// Bertanggung jawab mengubah raw JSON dari data source menjadi domain entity.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final rawJson = await _remoteDataSource.login(email, password);
    return UserEntity.fromBackendJson(rawJson);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await DioClient().clearSession();
  }
}
