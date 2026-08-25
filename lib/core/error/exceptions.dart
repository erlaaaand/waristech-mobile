/// Kelas exception terpusat untuk seluruh aplikasi.
/// Menerapkan DRY: satu tempat untuk semua jenis kegagalan.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException(this.message, {this.statusCode, this.code});

  /// Parse error dari respons DioException secara seragam.
  factory AppException.fromDioError(dynamic error) {
    if (error?.response != null) {
      final data = error.response?.data;
      String msg = 'Kesalahan tidak diketahui';

      if (data is Map<String, dynamic>) {
        final raw = data['message'];
        msg = raw is List ? raw.first.toString() : raw?.toString() ?? msg;
      }
      return AppException(msg, statusCode: error.response?.statusCode);
    }
    return AppException('Koneksi gagal: ${error?.message ?? 'Network error'}');
  }

  @override
  String toString() => message;
}

/// Exception khusus untuk kondisi tidak terautentikasi.
class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Sesi berakhir. Silakan login kembali.', statusCode: 401, code: 'UNAUTHORIZED');
}

/// Exception khusus saat parsing data gagal.
class DataParseException extends AppException {
  const DataParseException(String field)
      : super('Gagal memuat data: field "$field" tidak ditemukan.', code: 'PARSE_ERROR');
}
