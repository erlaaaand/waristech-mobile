import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk fitur autentikasi.
/// Mewarisi [BaseRemoteDataSource] untuk DRY error handling.
class AuthRemoteDataSource extends BaseRemoteDataSource {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Ambil dan simpan CSRF token sebelum setiap operasi.
  Future<void> fetchAndStoreCsrfToken() async {
    try {
      final response = await dio.get<dynamic>('/csrf-token');
      final token = response.data?['csrfToken'] as String?;
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: 'csrfToken', value: token);
      }
    } catch (_) {
      // CSRF fetch bersifat best-effort; jangan blokir proses
    }
  }

  /// Login dengan email dan password.
  /// Backend mengembalikan: { message, user: { id, email, fullName, role } }
  /// dan menyimpan accessToken di HttpOnly Cookie.
  Future<Map<String, dynamic>> login(String email, String password) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      final response = await dio.post<dynamic>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    });
  }

  /// GET /auth/me — verifikasi token yang tersimpan masih valid.
  /// Backend mengembalikan: { userId, email, role, ... }
  Future<Map<String, dynamic>> getMe() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/auth/me');
      return response.data as Map<String, dynamic>;
    });
  }

  /// Logout — hapus cookie di backend.
  Future<void> logout() async {
    try {
      await fetchAndStoreCsrfToken();
      await dio.post<dynamic>('/auth/logout');
    } catch (_) {
      // Logout best-effort; jangan blokir proses
    }
  }

  /// POST /auth/register/pewaris — akun dibuat NON-AKTIF, OTP dikirim ke email.
  Future<void> registerPewaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nik,
    required bool consentAgreed,
  }) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      await dio.post<dynamic>(
        '/auth/register/pewaris',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'nik': nik,
          'consentAgreed': consentAgreed,
        },
      );
    });
  }

  /// POST /auth/register/ahli-waris — butuh kode undangan dari Pewaris.
  Future<void> registerAhliWaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String invitationCode,
    required bool consentAgreed,
  }) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      await dio.post<dynamic>(
        '/auth/register/ahli-waris',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'invitationCode': invitationCode,
          'consentAgreed': consentAgreed,
        },
      );
    });
  }

  /// POST /auth/verify-email — sukses akan mengaktifkan akun & langsung
  /// membuat sesi (cookie accessToken diset backend, sama seperti login).
  Future<Map<String, dynamic>> verifyEmail(String email, String otp) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      final response = await dio.post<dynamic>(
        '/auth/verify-email',
        data: {'email': email, 'otp': otp},
      );
      return response.data as Map<String, dynamic>;
    });
  }

  /// POST /auth/resend-otp — kirim ulang kode OTP verifikasi email.
  Future<void> resendOtp(String email) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      await dio.post<dynamic>('/auth/resend-otp', data: {'email': email});
    });
  }

  /// POST /auth/forgot-password — kirim OTP reset password ke email.
  /// Backend SELALU mengembalikan pesan generik yang sama baik email
  /// terdaftar atau tidak (anti-enumeration) — jangan disimpulkan sebaliknya.
  Future<String> forgotPassword(String email) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      final response = await dio.post<dynamic>(
        '/auth/forgot-password',
        data: {'email': email},
      );
      final data = response.data as Map<String, dynamic>;
      return data['message']?.toString() ?? 'Permintaan berhasil dikirim.';
    });
  }

  /// POST /auth/reset-password — tukar OTP reset dengan password baru.
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      final response = await dio.post<dynamic>(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      final data = response.data as Map<String, dynamic>;
      return data['message']?.toString() ?? 'Password berhasil direset.';
    });
  }

  /// POST /auth/magic-link/verify — login sementara untuk Guest (Saksi)
  /// memakai token dari tautan email + OTP. Token & OTP sekali pakai.
  /// Sukses akan membuat sesi Guest (cookie accessToken, berlaku 1 hari).
  Future<Map<String, dynamic>> verifyMagicLink({
    required String token,
    required String otp,
  }) {
    return safeCall(() async {
      await fetchAndStoreCsrfToken();
      final response = await dio.post<dynamic>(
        '/auth/magic-link/verify',
        data: {'token': token, 'otp': otp},
      );
      return response.data as Map<String, dynamic>;
    });
  }
}
