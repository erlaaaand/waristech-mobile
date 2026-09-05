import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk preferensi skema hukum waris.
/// Backend: PATCH/GET /calculation/preference.
class CalculationRemoteDataSource extends BaseRemoteDataSource {
  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort
    }
  }

  /// GET /calculation/preference -> { preferredCalculationMethod: string|null }
  Future<String?> getPreference() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/calculation/preference');
      final data = unwrapData(response.data) as Map<String, dynamic>;
      return data['preferredCalculationMethod'] as String?;
    });
  }

  /// PATCH /calculation/preference { method } -> { preferredCalculationMethod }
  Future<String> setPreference(String method) {
    return safeCall(() async {
      await _ensureCsrf();
      final response = await dio.patch<dynamic>(
        '/calculation/preference',
        data: {'method': method},
      );
      final data = unwrapData(response.data) as Map<String, dynamic>;
      return data['preferredCalculationMethod'] as String;
    });
  }

  /// GET /calculation/dashboard — ringkasan jumlah aset & anggota keluarga.
  Future<Map<String, dynamic>> getDashboard() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/calculation/dashboard');
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// POST /calculation/simulate — simulasikan pembagian waris (belum
  /// disimpan). `customaryRatios` wajib diisi jika `method` = CUSTOMARY.
  Future<Map<String, dynamic>> simulate({
    required String method,
    List<Map<String, dynamic>>? customaryRatios,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      final body = <String, dynamic>{
        'method': method,
        'customaryRatios': ?customaryRatios,
      };
      final response = await dio.post<dynamic>(
        '/calculation/simulate',
        data: body,
      );
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }
}
