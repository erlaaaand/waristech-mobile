import 'package:wt_mobile/features/assets/data/datasources/asset_remote_data_source.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
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
}
