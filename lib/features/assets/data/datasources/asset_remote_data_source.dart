import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk fitur aset.
class AssetRemoteDataSource extends BaseRemoteDataSource {
  /// Ambil dan simpan CSRF token sebelum operasi yang mengubah data.
  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort, interceptor DioClient sudah menangani penyimpanan token
    }
  }

  /// Ambil daftar aset milik user yang sedang login.
  Future<List<dynamic>> fetchMyAssets() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/assets');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// Ambil daftar aset yang teralokasi ke Ahli Waris yang sedang login.
  Future<List<dynamic>> fetchAllocatedAssets() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/assets/ahli-waris/allocated');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// POST /assets — buat aset baru. `secret` wajib untuk custodyType VAULT,
  /// diabaikan untuk GUIDANCE.
  Future<Map<String, dynamic>> createAsset({
    required String type,
    required String assetName,
    required String platform,
    required String accountIdentifier,
    required String assignedNotarisId,
    required String custodyType,
    String? inheritanceScheme,
    Map<String, dynamic>? secret,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      final body = <String, dynamic>{
        'type': type,
        'assetName': assetName,
        'platform': platform,
        'accountIdentifier': accountIdentifier,
        'assignedNotarisId': assignedNotarisId,
        'custodyType': custodyType,
        'inheritanceScheme': ?inheritanceScheme,
        'secret': ?secret,
      };
      final response = await dio.post<dynamic>('/assets', data: body);
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// PATCH /assets/:id — hanya dipakai untuk mengubah skema waris sebelum
  /// terkunci (Notaris belum memverifikasi aset).
  Future<Map<String, dynamic>> updateAssetScheme({
    required String assetId,
    required String inheritanceScheme,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      final response = await dio.patch<dynamic>(
        '/assets/$assetId',
        data: {'inheritanceScheme': inheritanceScheme},
      );
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// GET /assets/:id/guidance — panduan dokumen & langkah resmi (GUIDANCE).
  Future<Map<String, dynamic>> getGuidance(String assetId) {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/assets/$assetId/guidance');
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// GET /assets/:id/secret — TIDAK mengembalikan plaintext, hanya bagian
  /// kunci SYSTEM (+ ciphertext bagian NOTARIS bila ada). Penggabungan
  /// (Shamir combine) WAJIB dilakukan di klien.
  Future<Map<String, dynamic>> unlockAsset(String assetId) {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/assets/$assetId/secret');
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// POST /assets/:id/allocate — (Pewaris) alokasikan persentase aset ke
  /// Ahli Waris tertentu. `reason` wajib bila `percentage` menyimpang dari
  /// hasil hitungan skema hukum waris pilihan.
  Future<Map<String, dynamic>> allocateAsset({
    required String assetId,
    required String ahliWarisId,
    required double percentage,
    bool? isExecutor,
    String? reason,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      final body = <String, dynamic>{
        'ahliWarisId': ahliWarisId,
        'percentage': percentage,
        'isExecutor': ?isExecutor,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };
      final response = await dio.post<dynamic>(
        '/assets/$assetId/allocate',
        data: body,
      );
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }

  /// POST /assets/:id/liquidation-proof — (Eksekutor) unggah bukti
  /// pencairan e-Statement (URL dari POST /storage/upload) + SPTJM.
  Future<void> uploadLiquidationProof({
    required String assetId,
    required String pdfFileUrl,
    String? pdfPassword,
    required bool sptjmAgreed,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>(
        '/assets/$assetId/liquidation-proof',
        data: {
          'pdfFileUrl': pdfFileUrl,
          if (pdfPassword != null && pdfPassword.isNotEmpty)
            'pdfPassword': pdfPassword,
          'sptjmAgreed': sptjmAgreed,
        },
      );
    });
  }

  /// POST /assets/:id/acknowledge — (Ahli Waris non-Eksekutor) konfirmasi
  /// dana warisan telah diterima.
  Future<void> acknowledgeDistribution(String assetId) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>('/assets/$assetId/acknowledge');
    });
  }

  /// GET /assets/notaris/liquidation-reviews — (Notaris) daftar bukti
  /// pencairan yang menunggu tinjauan.
  Future<List<dynamic>> getPendingLiquidationReviews() {
    return safeCall(() async {
      final response = await dio.get<dynamic>(
        '/assets/notaris/liquidation-reviews',
      );
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// PATCH /assets/liquidation-proofs/:proofId/review — (Notaris) putuskan
  /// bukti pencairan. `notes` wajib diisi bila `decision` = REJECT.
  Future<void> reviewLiquidationProof({
    required String proofId,
    required String decision,
    String? notes,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.patch<dynamic>(
        '/assets/liquidation-proofs/$proofId/review',
        data: {
          'decision': decision,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
    });
  }

  /// POST /assets/:id/notaris-share — (Pewaris) titipkan bagian kunci
  /// NOTARIS yang SUDAH dienkripsi di sisi klien (RSA-OAEP, base64).
  Future<void> escrowNotarisShare({
    required String assetId,
    required String notarisId,
    required String encryptedShare,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>(
        '/assets/$assetId/notaris-share',
        data: {'notarisId': notarisId, 'encryptedShare': encryptedShare},
      );
    });
  }

  /// POST /assets/:id/rotate-shares — (Pewaris) rotasi bagian kunci aset.
  /// `newSystemShare` hasil pemecahan ULANG di sisi klien.
  Future<void> rotateKeyShares({
    required String assetId,
    required String newSystemShare,
    String? newNotarisEncryptedShare,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>(
        '/assets/$assetId/rotate-shares',
        data: {
          'newSystemShare': newSystemShare,
          'newNotarisEncryptedShare': ?newNotarisEncryptedShare,
        },
      );
    });
  }

  /// POST /assets/:id/legal-fallback — ajukan jalur pemulihan hukum
  /// konvensional. TIDAK memulihkan kunci — hanya panduan resmi & audit trail.
  Future<Map<String, dynamic>> requestLegalFallback({
    required String assetId,
    required String reason,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      final response = await dio.post<dynamic>(
        '/assets/$assetId/legal-fallback',
        data: {'reason': reason},
      );
      return unwrapData(response.data) as Map<String, dynamic>;
    });
  }
}
