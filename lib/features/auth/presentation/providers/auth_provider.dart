import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wt_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wt_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:wt_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Provider untuk [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDataSource());
});

/// State notifier yang mengelola siklus hidup sesi pengguna.
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Cek session yang tersimpan saat startup
    _restoreSession();
  }

  /// Coba restore session dari token yang tersimpan.
  /// Dipanggil otomatis saat aplikasi dibuka.
  Future<void> _restoreSession() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null || token.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final user = await _repository.getMe();
      state = AsyncValue.data(user);
    } catch (_) {
      // Token kadaluarsa atau tidak valid — hapus dan redirect ke login
      await storage.delete(key: 'accessToken');
      state = const AsyncValue.data(null);
    }
  }

  /// Login ke backend dengan kredensial nyata.
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.login(email, password),
    );
  }

  /// Logout dan hapus sesi pengguna.
  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

/// Provider utama untuk state autentikasi.
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
