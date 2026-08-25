import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk fitur autentikasi.
/// Mewarisi [BaseRemoteDataSource] untuk DRY error handling.
class AuthRemoteDataSource extends BaseRemoteDataSource {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Ambil dan simpan CSRF token sebelum setiap operasi.
  Future<void> fetchAndStoreCsrfToken() async {
    try {
      final response = await dio.get('/csrf-token');
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
      final response = await dio.post(
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
      final response = await dio.get('/auth/me');
      return response.data as Map<String, dynamic>;
    });
  }

  /// Logout — hapus cookie di backend.
  Future<void> logout() async {
    try {
      await fetchAndStoreCsrfToken();
      await dio.post('/auth/logout');
    } catch (_) {
      // Logout best-effort; jangan blokir proses
    }
  }
}
