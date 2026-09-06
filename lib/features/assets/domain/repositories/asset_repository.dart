import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_guidance_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/create_asset_result_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/unlock_result_entity.dart';

/// Kontrak domain untuk aset.
abstract class AssetRepository {
  Future<List<AssetEntity>> fetchMyAssets();
  Future<List<AssetEntity>> fetchAllocatedAssets();

  Future<CreateAssetResultEntity> createAsset({
    required String type,
    required String assetName,
    required String platform,
    required String accountIdentifier,
    required String assignedNotarisId,
    required String custodyType,
    Map<String, dynamic>? secret,
  });

  Future<AssetGuidanceEntity> getGuidance(String assetId);

  Future<UnlockResultEntity> unlockAsset(String assetId);

  Future<void> allocateAsset({
    required String assetId,
    required String ahliWarisId,
    required double percentage,
    bool? isExecutor,
    String? reason,
  });

  Future<void> uploadLiquidationProof({
    required String assetId,
    required String pdfFileUrl,
    String? pdfPassword,
    required bool sptjmAgreed,
  });

  Future<void> acknowledgeDistribution(String assetId);

  Future<List<LiquidationProofEntity>> getPendingLiquidationReviews();

  Future<void> reviewLiquidationProof({
    required String proofId,
    required String decision,
    String? notes,
  });

  Future<void> escrowNotarisShare({
    required String assetId,
    required String notarisId,
    required String encryptedShare,
  });

  Future<void> rotateKeyShares({
    required String assetId,
    required String newSystemShare,
    String? newNotarisEncryptedShare,
  });

  Future<Map<String, dynamic>> requestLegalFallback({
    required String assetId,
    required String reason,
  });
}
