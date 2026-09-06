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
      return UserEntity.fromBackendJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
    await DioClient().clearSession();
  }

  @override
  Future<void> registerPewaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nik,
    required bool consentAgreed,
  }) {
    return _dataSource.registerPewaris(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      nik: nik,
      consentAgreed: consentAgreed,
    );
  }

  @override
  Future<void> registerAhliWaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String invitationCode,
    required bool consentAgreed,
  }) {
    return _dataSource.registerAhliWaris(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      invitationCode: invitationCode,
      consentAgreed: consentAgreed,
    );
  }

  @override
  Future<UserEntity> verifyEmail(String email, String otp) async {
    final json = await _dataSource.verifyEmail(email, otp);
    return UserEntity.fromBackendJson(json);
  }

  @override
  Future<void> resendOtp(String email) => _dataSource.resendOtp(email);

  @override
  Future<String> forgotPassword(String email) =>
      _dataSource.forgotPassword(email);

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _dataSource.resetPassword(email: email, otp: otp, newPassword: newPassword);

  @override
  Future<UserEntity> verifyMagicLink({
    required String token,
    required String otp,
  }) async {
    final json = await _dataSource.verifyMagicLink(token: token, otp: otp);
    return UserEntity.fromBackendJson(json);
  }
}
