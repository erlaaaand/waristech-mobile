import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk notifikasi/aktivitas milik user yang sedang login.
class NotificationRemoteDataSource extends BaseRemoteDataSource {
  /// GET /notifications — daftar notifikasi milik user saat ini.
  Future<List<dynamic>> getMyNotifications() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/notifications');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }
}
