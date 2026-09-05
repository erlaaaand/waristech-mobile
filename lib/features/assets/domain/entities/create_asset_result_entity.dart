import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_guidance_entity.dart';

/// Cocok dengan `CreateAssetResponseDto` backend.
///
/// PENTING: [executorShare] & [notarisShare] hanya muncul SATU KALI pada
/// respons ini (custodyType VAULT) — server tidak pernah menyimpannya dan
/// tidak dapat mengembalikannya lagi lewat endpoint mana pun. Untuk
/// custodyType GUIDANCE, keduanya null dan [guidance] terisi sebagai gantinya.
class CreateAssetResultEntity {
  final AssetEntity asset;
  final String? executorShare;
  final String? notarisShare;
  final AssetGuidanceEntity? guidance;
  final String warning;

  const CreateAssetResultEntity({
    required this.asset,
    required this.warning,
    this.executorShare,
    this.notarisShare,
    this.guidance,
  });

  bool get isVault => executorShare != null && notarisShare != null;

  factory CreateAssetResultEntity.fromJson(Map<String, dynamic> json) {
    return CreateAssetResultEntity(
      asset: AssetEntity.fromJson(json['asset'] as Map<String, dynamic>),
      executorShare: json['executorShare'] as String?,
      notarisShare: json['notarisShare'] as String?,
      guidance: json['guidance'] != null
          ? AssetGuidanceEntity.fromJson(
              json['guidance'] as Map<String, dynamic>,
            )
          : null,
      warning: json['warning']?.toString() ?? '',
    );
  }
}
