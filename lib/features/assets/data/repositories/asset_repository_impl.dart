import 'package:wt_mobile/features/assets/data/datasources/asset_remote_data_source.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_guidance_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/create_asset_result_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/unlock_result_entity.dart';
import 'package:wt_mobile/features/assets/domain/repositories/asset_repository.dart';

/// Implementasi konkret dari [AssetRepository].
class AssetRepositoryImpl implements AssetRepository {
  final AssetRemoteDataSource _remoteDataSource;

  AssetRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AssetEntity>> fetchMyAssets() async {
    final raw = await _remoteDataSource.fetchMyAssets();
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AssetEntity.fromJson)
        .toList();
  }

  @override
  Future<List<AssetEntity>> fetchAllocatedAssets() async {
    final raw = await _remoteDataSource.fetchAllocatedAssets();
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AssetEntity.fromJson)
        .toList();
  }

  @override
  Future<CreateAssetResultEntity> createAsset({
    required String type,
    required String assetName,
    required String platform,
    required String accountIdentifier,
    required String assignedNotarisId,
    required String custodyType,
    Map<String, dynamic>? secret,
  }) async {
    final json = await _remoteDataSource.createAsset(
      type: type,
      assetName: assetName,
      platform: platform,
      accountIdentifier: accountIdentifier,
      assignedNotarisId: assignedNotarisId,
      custodyType: custodyType,
      secret: secret,
    );
    return CreateAssetResultEntity.fromJson(json);
  }

  @override
  Future<AssetGuidanceEntity> getGuidance(String assetId) async {
    final json = await _remoteDataSource.getGuidance(assetId);
    return AssetGuidanceEntity.fromJson(json);
  }

  @override
  Future<UnlockResultEntity> unlockAsset(String assetId) async {
    final json = await _remoteDataSource.unlockAsset(assetId);
    return UnlockResultEntity.fromJson(json);
  }

  @override
  Future<void> allocateAsset({
    required String assetId,
    required String ahliWarisId,
    required double percentage,
    bool? isExecutor,
    String? reason,
  }) {
    return _remoteDataSource.allocateAsset(
      assetId: assetId,
      ahliWarisId: ahliWarisId,
      percentage: percentage,
      isExecutor: isExecutor,
      reason: reason,
    );
  }

  @override
  Future<void> uploadLiquidationProof({
    required String assetId,
    required String pdfFileUrl,
    String? pdfPassword,
    required bool sptjmAgreed,
  }) {
    return _remoteDataSource.uploadLiquidationProof(
      assetId: assetId,
      pdfFileUrl: pdfFileUrl,
      pdfPassword: pdfPassword,
      sptjmAgreed: sptjmAgreed,
    );
  }

  @override
  Future<void> acknowledgeDistribution(String assetId) {
    return _remoteDataSource.acknowledgeDistribution(assetId);
  }

  @override
  Future<List<LiquidationProofEntity>> getPendingLiquidationReviews() async {
    final raw = await _remoteDataSource.getPendingLiquidationReviews();
    return raw
        .whereType<Map<String, dynamic>>()
        .map(LiquidationProofEntity.fromJson)
        .toList();
  }

  @override
  Future<void> reviewLiquidationProof({
    required String proofId,
    required String decision,
    String? notes,
  }) {
    return _remoteDataSource.reviewLiquidationProof(
      proofId: proofId,
      decision: decision,
      notes: notes,
    );
  }

  @override
  Future<void> escrowNotarisShare({
    required String assetId,
    required String notarisId,
    required String encryptedShare,
  }) {
    return _remoteDataSource.escrowNotarisShare(
      assetId: assetId,
      notarisId: notarisId,
      encryptedShare: encryptedShare,
    );
  }

  @override
  Future<void> rotateKeyShares({
    required String assetId,
    required String newSystemShare,
    String? newNotarisEncryptedShare,
  }) {
    return _remoteDataSource.rotateKeyShares(
      assetId: assetId,
      newSystemShare: newSystemShare,
      newNotarisEncryptedShare: newNotarisEncryptedShare,
    );
  }

  @override
  Future<Map<String, dynamic>> requestLegalFallback({
    required String assetId,
    required String reason,
  }) {
    return _remoteDataSource.requestLegalFallback(
      assetId: assetId,
      reason: reason,
    );
  }
}
