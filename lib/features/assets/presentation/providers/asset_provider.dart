import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/assets/data/datasources/asset_remote_data_source.dart';
import 'package:wt_mobile/features/assets/data/repositories/asset_repository_impl.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/domain/repositories/asset_repository.dart';

/// Provider untuk [AssetRepository].
/// Presentation layer menggunakan interface, bukan implementasi.
final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepositoryImpl(AssetRemoteDataSource());
});

/// Provider untuk daftar aset milik user yang sedang login.
final myAssetsProvider = FutureProvider<List<AssetEntity>>((ref) {
  return ref.watch(assetRepositoryProvider).fetchMyAssets();
});
