import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';

/// Kontrak domain untuk aset.
abstract class AssetRepository {
  Future<List<AssetEntity>> fetchMyAssets();
}
