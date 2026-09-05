import 'package:dio/dio.dart';

/// Kelas exception terpusat untuk seluruh aplikasi.
/// Menerapkan DRY: satu tempat untuk semua jenis kegagalan.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException(this.message, {this.statusCode, this.code});

  /// Parse error dari respons [DioException] secara seragam.
  ///
  /// Parameter sengaja bertipe [DioException], bukan `dynamic`: dengan
  /// `strict-casts` aktif, akses anggota lewat `dynamic` tidak lagi
  /// terverifikasi compiler dan bisa meledak saat runtime.
  factory AppException.fromDioError(DioException error) {
    final Response<dynamic>? response = error.response;
    if (response != null) {
      final Object? data = response.data;
      String msg = 'Kesalahan tidak diketahui';

      if (data is Map<String, dynamic>) {
        final Object? raw = data['message'];
        if (raw is List) {
          if (raw.isNotEmpty) msg = raw.first.toString();
        } else if (raw != null) {
          msg = raw.toString();
        }
      }
      return AppException(msg, statusCode: response.statusCode);
    }
    return AppException('Koneksi gagal: ${error.message ?? 'Network error'}');
  }

  @override
  String toString() => message;
}

/// Exception khusus untuk kondisi tidak terautentikasi.
class UnauthorizedException extends AppException {
  const UnauthorizedException()
    : super(
        'Sesi berakhir. Silakan login kembali.',
        statusCode: 401,
        code: 'UNAUTHORIZED',
      );
}

/// Exception khusus saat parsing data gagal.
class DataParseException extends AppException {
  const DataParseException(String field)
    : super(
        'Gagal memuat data: field "$field" tidak ditemukan.',
        code: 'PARSE_ERROR',
      );
}
