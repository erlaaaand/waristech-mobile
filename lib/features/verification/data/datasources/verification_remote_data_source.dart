import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk fitur verifikasi (Notaris/Verifikator).
class VerificationRemoteDataSource extends BaseRemoteDataSource {
  /// Ambil daftar permohonan verifikasi yang belum diproses.
  Future<List<dynamic>> fetchPendingRequests() {
    return safeCall(() async {
      final response = await dio.get('/verifications/pending');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// Setujui permohonan verifikasi dan rilis kunci enkripsi.
  Future<void> approve(String verificationId) {
    return safeCall(() async {
      await dio.post('/verifications/$verificationId/approve');
    });
  }

  /// Tolak permohonan verifikasi dengan alasan penolakan.
  Future<void> reject(String verificationId, {required String reason}) {
    return safeCall(() async {
      await dio.post('/verifications/$verificationId/reject', data: {
        'reason': reason,
      });
    });
  }

  /// Ambil riwayat keputusan verifikasi yang sudah diproses.
  Future<List<dynamic>> fetchHistory() {
    return safeCall(() async {
      final response = await dio.get('/verifications/history');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }
}
