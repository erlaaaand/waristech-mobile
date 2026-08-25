import 'package:dio/dio.dart';
import 'package:wt_mobile/core/error/exceptions.dart';
import 'package:wt_mobile/core/network/dio_client.dart';

/// Kelas dasar untuk semua remote data source.
/// Menyediakan:
/// - Akses Dio singleton
/// - Method [safeCall] untuk DRY error handling
/// - Method [unwrapData] untuk menormalisasi respons `TransformInterceptor`
abstract class BaseRemoteDataSource {
  final Dio dio = DioClient().dio;

  /// Eksekusi request Dio dengan error handling terpusat.
  /// Semua DioException diubah menjadi [AppException].
  Future<T> safeCall<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  /// Normalisasi respons dari NestJS TransformInterceptor.
  /// Backend selalu membungkus data dalam `{ data: ... }`.
  /// Jika data adalah List, kembalikan langsung.
  /// Jika data adalah Map dengan key 'data', kembalikan value-nya.
  dynamic unwrapData(dynamic rawData) {
    if (rawData is List) return rawData;
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      return rawData['data'];
    }
    return rawData;
  }
}
