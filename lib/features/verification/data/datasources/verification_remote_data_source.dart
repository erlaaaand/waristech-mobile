import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk aksi verifikasi aset oleh Notaris.
/// Endpoint: PATCH /assets/:id/verify & PATCH /assets/:id/reject
class VerificationRemoteDataSource extends BaseRemoteDataSource {
  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort — DioClient sudah menyimpan token CSRF sejak login.
    }
  }

  /// Ambil daftar aset dengan status PENDING_VERIFICATION.
  Future<List<dynamic>> fetchPendingAssets() {
    return safeCall(() async {
      // Notaris mengakses list aset yang menunggu verifikasi
      final response = await dio.get<dynamic>('/assets/notaris/pending');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// Setujui verifikasi aset (Notaris).
  /// Backend: PATCH /assets/:id/verify
  Future<Map<String, dynamic>> verifyAsset(String assetId) {
    return safeCall(() async {
      final response = await dio.patch<dynamic>('/assets/$assetId/verify');
      return response.data as Map<String, dynamic>? ?? {};
    });
  }

  /// Tolak verifikasi aset (Notaris).
  /// Backend: PATCH /assets/:id/reject
  Future<Map<String, dynamic>> rejectAsset(String assetId) {
    return safeCall(() async {
      final response = await dio.patch<dynamic>('/assets/$assetId/reject');
      return response.data as Map<String, dynamic>? ?? {};
    });
  }

  /// Tutup kasus — hapus data rahasia (cryptographic wipe).
  /// Backend: PATCH /assets/:id/close
  Future<void> closeAsset(String assetId) {
    return safeCall(() async {
      await dio.patch<dynamic>('/assets/$assetId/close');
    });
  }

  /// Verifikasi dokumen akta kematian (Notaris).
  /// Backend: PATCH /inheritance/death-certificate/:id/verify
  ///
  /// CATATAN: backend belum menyediakan endpoint daftar dokumen yang
  /// menunggu tinjauan — id diperoleh manual (mis. dari Pewaris/keluarga)
  /// sampai endpoint listing tersebut dibangun.
  Future<void> verifyDeathCertificate(String deathVerificationId) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.patch<dynamic>(
        '/inheritance/death-certificate/$deathVerificationId/verify',
      );
    });
  }

  /// Ambil riwayat aset yang sudah diverifikasi/ditolak.
  Future<List<dynamic>> fetchHistory() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/assets/notaris/history');
      final unwrapped = unwrapData(response.data);
      if (unwrapped is! List) return [];
      // Filter yang sudah diproses
      return (unwrapped)
          .where(
            (a) => ['VERIFIED', 'REJECTED', 'CLOSED'].contains(a['status']),
          )
          .toList();
    });
  }
}
