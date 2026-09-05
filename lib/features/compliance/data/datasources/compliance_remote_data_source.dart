import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk persetujuan pemrosesan data pribadi (UU PDP).
class ComplianceRemoteDataSource extends BaseRemoteDataSource {
  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort — DioClient sudah menyimpan token CSRF sejak login.
    }
  }

  /// GET /compliance/consent — status persetujuan saat ini.
  Future<Map<String, dynamic>> getMyConsent() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/compliance/consent');
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// POST /compliance/consent — beri/perbarui persetujuan (dipakai saat
  /// versi kebijakan privasi berubah).
  Future<Map<String, dynamic>> grantConsent() {
    return safeCall(() async {
      await _ensureCsrf();
      final response = await dio.post<dynamic>('/compliance/consent');
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }
}
