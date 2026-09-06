import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/storage/secure_key_share_storage.dart';
import 'package:wt_mobile/core/network/dio_client.dart';
import 'package:wt_mobile/features/assets/data/datasources/asset_remote_data_source.dart';
import 'package:wt_mobile/features/assets/data/repositories/asset_repository_impl.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/create_asset_result_entity.dart';
import 'package:wt_mobile/features/assets/domain/repositories/asset_repository.dart';

/// Provider untuk daftar Notaris yang bisa dipilih saat membuat aset
final notariesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = DioClient().dio;
  final response = await dio.get<dynamic>('/users/notaries');
  final responseData = response.data as Map<String, dynamic>;
  final data = responseData['data'];
  return (data as List).cast<Map<String, dynamic>>();
});

/// Provider untuk [AssetRepository].
/// Presentation layer menggunakan interface, bukan implementasi.
final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepositoryImpl(AssetRemoteDataSource());
});

/// Provider untuk daftar aset milik user yang sedang login (Pewaris).
final myAssetsProvider = FutureProvider.autoDispose<List<AssetEntity>>((ref) {
  return ref.watch(assetRepositoryProvider).fetchMyAssets();
});

/// Provider untuk daftar aset yang teralokasi ke user (Ahli Waris) — dipakai
/// layar Brankas (Fase 3).
final allocatedAssetsProvider = FutureProvider.autoDispose<List<AssetEntity>>((
  ref,
) {
  return ref.watch(assetRepositoryProvider).fetchAllocatedAssets();
});

/// Notifier untuk alur pembuatan aset (VAULT/GUIDANCE). Hasil sukses berisi
/// bagian kunci sekali-pakai (VAULT) atau panduan resmi (GUIDANCE).
class CreateAssetNotifier
    extends StateNotifier<AsyncValue<CreateAssetResultEntity?>> {
  final AssetRepository _repository;
  final Ref _ref;

  CreateAssetNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> create({
    required String type,
    required String assetName,
    required String platform,
    required String accountIdentifier,
    required String assignedNotarisId,
    required String custodyType,
    Map<String, dynamic>? secret,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.createAsset(
        type: type,
        assetName: assetName,
        platform: platform,
        accountIdentifier: accountIdentifier,
        assignedNotarisId: assignedNotarisId,
        custodyType: custodyType,
        secret: secret,
      );

      // Simpan bagian kunci Eksekutor SEKARANG JUGA — ini satu-satunya
      // kesempatan menerimanya, tidak akan pernah dikirim ulang oleh server.
      if (result.executorShare != null) {
        await SecureKeyShareStorage.saveExecutorShare(
          result.asset.id,
          result.executorShare!,
        );
      }

      _ref.invalidate(myAssetsProvider);
      return result;
    });
  }

  void reset() => state = const AsyncValue.data(null);
}

final createAssetProvider =
    StateNotifierProvider.autoDispose<
      CreateAssetNotifier,
      AsyncValue<CreateAssetResultEntity?>
    >((ref) {
      return CreateAssetNotifier(ref.watch(assetRepositoryProvider), ref);
    });

// ---------------------------------------------------------------------------
// Fase 7 — Alokasi & Bukti Pencairan
// ---------------------------------------------------------------------------

/// Notifier alokasi aset (Pewaris) — satu instance per assetId.
class AllocateAssetNotifier extends StateNotifier<AsyncValue<void>> {
  final AssetRepository _repository;
  final Ref _ref;
  AllocateAssetNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> allocate({
    required String assetId,
    required String ahliWarisId,
    required double percentage,
    bool? isExecutor,
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.allocateAsset(
        assetId: assetId,
        ahliWarisId: ahliWarisId,
        percentage: percentage,
        isExecutor: isExecutor,
        reason: reason,
      ),
    );
    if (!state.hasError) _ref.invalidate(myAssetsProvider);
  }
}

final allocateAssetProvider = StateNotifierProvider.autoDispose
    .family<AllocateAssetNotifier, AsyncValue<void>, String>((ref, assetId) {
      return AllocateAssetNotifier(ref.watch(assetRepositoryProvider), ref);
    });

/// Notifier upload bukti pencairan (Eksekutor) — satu instance per assetId.
class UploadLiquidationProofNotifier extends StateNotifier<AsyncValue<void>> {
  final AssetRepository _repository;
  UploadLiquidationProofNotifier(this._repository)
    : super(const AsyncValue.data(null));

  Future<void> upload({
    required String assetId,
    required String pdfFileUrl,
    String? pdfPassword,
    required bool sptjmAgreed,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.uploadLiquidationProof(
        assetId: assetId,
        pdfFileUrl: pdfFileUrl,
        pdfPassword: pdfPassword,
        sptjmAgreed: sptjmAgreed,
      ),
    );
  }
}

final uploadLiquidationProofProvider = StateNotifierProvider.autoDispose
    .family<UploadLiquidationProofNotifier, AsyncValue<void>, String>((
      ref,
      assetId,
    ) {
      return UploadLiquidationProofNotifier(ref.watch(assetRepositoryProvider));
    });

/// Notifier konfirmasi penerimaan dana (Ahli Waris non-Eksekutor).
class AcknowledgeDistributionNotifier extends StateNotifier<AsyncValue<void>> {
  final AssetRepository _repository;
  final Ref _ref;
  AcknowledgeDistributionNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> acknowledge(String assetId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.acknowledgeDistribution(assetId),
    );
    if (!state.hasError) _ref.invalidate(allocatedAssetsProvider);
  }
}

final acknowledgeDistributionProvider = StateNotifierProvider.autoDispose
    .family<AcknowledgeDistributionNotifier, AsyncValue<void>, String>((
      ref,
      assetId,
    ) {
      return AcknowledgeDistributionNotifier(
        ref.watch(assetRepositoryProvider),
        ref,
      );
    });

/// Daftar bukti pencairan yang menunggu tinjauan (Notaris).
final pendingLiquidationReviewsProvider =
    FutureProvider.autoDispose<List<LiquidationProofEntity>>((ref) {
      return ref.watch(assetRepositoryProvider).getPendingLiquidationReviews();
    });

/// Notifier keputusan tinjauan bukti pencairan (Notaris) — per proofId.
class ReviewLiquidationProofNotifier extends StateNotifier<AsyncValue<void>> {
  final AssetRepository _repository;
  final Ref _ref;
  ReviewLiquidationProofNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> review({
    required String proofId,
    required String decision,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.reviewLiquidationProof(
        proofId: proofId,
        decision: decision,
        notes: notes,
      ),
    );
    if (!state.hasError) _ref.invalidate(pendingLiquidationReviewsProvider);
  }
}

final reviewLiquidationProofProvider = StateNotifierProvider.autoDispose
    .family<ReviewLiquidationProofNotifier, AsyncValue<void>, String>((
      ref,
      proofId,
    ) {
      return ReviewLiquidationProofNotifier(
        ref.watch(assetRepositoryProvider),
        ref,
      );
    });
