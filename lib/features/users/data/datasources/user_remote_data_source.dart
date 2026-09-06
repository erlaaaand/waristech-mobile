import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk PKI Notaris (public key registration & lookup).
class UserRemoteDataSource extends BaseRemoteDataSource {
  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort — DioClient sudah menyimpan token CSRF sejak login.
    }
  }

  /// POST /users/me/public-key — (Notaris) daftarkan public key RSA (PEM/SPKI).
  Future<void> registerPublicKey(String publicKeyPem) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>(
        '/users/me/public-key',
        data: {'publicKey': publicKeyPem},
      );
    });
  }

  /// PATCH /users/:id — perbarui nama dan/atau kata sandi. `currentPassword`
  /// & `newPassword` wajib dikirim BERSAMAAN bila ingin mengganti kata sandi.
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      final body = <String, dynamic>{
        'fullName': ?fullName,
        'email': ?email,
        'phone': ?phone,
        'currentPassword': ?currentPassword,
        'newPassword': ?newPassword,
      };
      final response = await dio.patch<dynamic>('/users/$userId', data: body);
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// PATCH /users/me/avatar — perbarui foto profil. `avatarUrl` didapat dari
  /// POST /storage/upload (purpose PROFILE_PHOTO) yang dilakukan sebelumnya.
  Future<Map<String, dynamic>> updateAvatar(String avatarUrl) {
    return safeCall(() async {
      await _ensureCsrf();
      final response = await dio.patch<dynamic>(
        '/users/me/avatar',
        data: {'avatarUrl': avatarUrl},
      );
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// GET /users/notaris/:id/public-key — ambil public key Notaris tujuan
  /// (dipakai untuk mengenkripsi bagian kunci NOTARIS sebelum dititipkan).
  Future<Map<String, dynamic>> getNotarisPublicKey(String notarisId) {
    return safeCall(() async {
      final response = await dio.get<dynamic>(
        '/users/notaris/$notarisId/public-key',
      );
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }
}
