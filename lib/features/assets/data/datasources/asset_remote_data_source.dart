import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk fitur aset.
class AssetRemoteDataSource extends BaseRemoteDataSource {
  /// Ambil daftar aset milik user yang sedang login.
  Future<List<dynamic>> fetchMyAssets() {
    return safeCall(() async {
      final response = await dio.get('/assets');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }
}
