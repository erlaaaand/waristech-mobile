import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wt_mobile/core/error/exceptions.dart';

/// HTTP client singleton berbasis Dio dengan interceptor otomatis untuk:
/// - Bearer token (JWT dari cookie)
/// - CSRF token
/// - Cookie forwarding
/// - Global error parsing ke [AppException]
class DioClient {
  static final DioClient _instance = DioClient._internal();

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl:
            dotenv.env['API_MAIN_URL'] ?? 'http://192.168.1.6:3001/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Interceptor handlers
  // ---------------------------------------------------------------------------

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'accessToken');
    final csrfToken = await _storage.read(key: 'csrfToken');
    final csrfCookie = await _storage.read(key: 'csrfCookie');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (csrfToken != null) {
      options.headers['X-CSRF-Token'] = csrfToken;
    }
    if (csrfCookie != null) {
      final existing = options.headers['Cookie'] as String? ?? '';
      options.headers['Cookie'] = existing.isEmpty
          ? 'x-csrf-token=$csrfCookie'
          : '$existing; x-csrf-token=$csrfCookie';
    }

    handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final setCookies = response.headers.map['set-cookie'];
    if (setCookies != null) {
      for (final cookie in setCookies) {
        final kv = cookie.split(';').first.trim();
        if (kv.startsWith('accessToken=')) {
          final val = kv.substring('accessToken='.length);
          if (val.isNotEmpty) await _storage.write(key: 'accessToken', value: val);
        } else if (kv.startsWith('x-csrf-token=')) {
          final val = kv.substring('x-csrf-token='.length);
          if (val.isNotEmpty) await _storage.write(key: 'csrfCookie', value: val);
        }
      }
    }
    handler.next(response);
  }

  void _onError(DioException e, ErrorInterceptorHandler handler) {
    if (e.response?.statusCode == 401) {
      handler.reject(
        DioException(
          requestOptions: e.requestOptions,
          error: const UnauthorizedException(),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }
    handler.next(e);
  }

  // ---------------------------------------------------------------------------
  // Helper: hapus token saat logout
  // ---------------------------------------------------------------------------
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: 'accessToken'),
      _storage.delete(key: 'csrfToken'),
      _storage.delete(key: 'csrfCookie'),
    ]);
  }
}
