import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';

/// Kontrak repository autentikasi.
abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity?> getMe();
  Future<void> logout();

  Future<void> registerPewaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nik,
    required bool consentAgreed,
  });

  Future<void> registerAhliWaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String invitationCode,
    required bool consentAgreed,
  });

  /// Verifikasi OTP email. Sukses akan langsung membuat sesi (mengaktifkan
  /// akun & login), sehingga mengembalikan [UserEntity] seperti [login].
  Future<UserEntity> verifyEmail(String email, String otp);

  Future<void> resendOtp(String email);

  /// Kirim OTP reset password ke email. Pesan yang dikembalikan SELALU
  /// generik (anti-enumeration) — jangan disimpulkan email pasti terdaftar.
  Future<String> forgotPassword(String email);

  /// Tukar OTP reset dengan password baru.
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  /// Verifikasi Guest (Saksi) via token magic link + OTP.
  /// Sukses membuat sesi Guest sementara (1 hari), mengembalikan [UserEntity].
  Future<UserEntity> verifyMagicLink({
    required String token,
    required String otp,
  });
}
