import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk aksi verifikasi aset oleh Notaris.
/// Endpoint: PATCH /assets/:id/verify & PATCH /assets/:id/reject
class VerificationRemoteDataSource extends BaseRemoteDataSource {
  /// Ambil daftar aset dengan status PENDING_VERIFICATION.
  Future<List<dynamic>> fetchPendingAssets() {
    return safeCall(() async {
      // Notaris mengakses list aset yang menunggu verifikasi
      final response = await dio.get('/assets');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// Setujui verifikasi aset (Notaris).
  /// Backend: PATCH /assets/:id/verify
  Future<Map<String, dynamic>> verifyAsset(String assetId) {
    return safeCall(() async {
      final response = await dio.patch('/assets/$assetId/verify');
      return response.data as Map<String, dynamic>? ?? {};
    });
  }

  /// Tolak verifikasi aset (Notaris).
  /// Backend: PATCH /assets/:id/reject
  Future<Map<String, dynamic>> rejectAsset(String assetId) {
    return safeCall(() async {
      final response = await dio.patch('/assets/$assetId/reject');
      return response.data as Map<String, dynamic>? ?? {};
    });
  }

  /// Tutup kasus — hapus data rahasia (cryptographic wipe).
  /// Backend: PATCH /assets/:id/close
  Future<void> closeAsset(String assetId) {
    return safeCall(() async {
      await dio.patch('/assets/$assetId/close');
    });
  }

  /// Ambil riwayat aset yang sudah diverifikasi/ditolak.
  Future<List<dynamic>> fetchHistory() {
    return safeCall(() async {
      final response = await dio.get('/assets');
      final unwrapped = unwrapData(response.data);
      if (unwrapped is! List) return [];
      // Filter yang sudah diproses
      return (unwrapped as List)
          .where((a) => ['VERIFIED', 'REJECTED', 'CLOSED'].contains(a['status']))
          .toList();
    });
  }
}
