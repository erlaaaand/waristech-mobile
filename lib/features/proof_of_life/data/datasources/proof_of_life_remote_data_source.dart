import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk Konfirmasi Keaktifan (Proof-of-Life) Pewaris.
/// Backend: POST /proof-of-life/check-in.
class ProofOfLifeRemoteDataSource extends BaseRemoteDataSource {
  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort — DioClient sudah menyimpan token CSRF sejak login.
    }
  }

  /// Konfirmasi status aktif — mencegah sistem memicu verifikasi kematian
  /// secara keliru. Idealnya dipanggil setiap ≤30 hari.
  Future<void> checkIn() {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>('/proof-of-life/check-in');
    });
  }

  /// GET /proof-of-life/status — waktu check-in terakhir, tahap saat ini,
  /// dan sisa hari sebelum jatuh tempo.
  Future<Map<String, dynamic>> getStatus() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/proof-of-life/status');
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }
}
