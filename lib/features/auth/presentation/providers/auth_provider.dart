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
    state = await AsyncValue.guard(() => _repository.login(email, password));
  }

  /// Verifikasi OTP email. Sukses = akun aktif + sesi langsung terbentuk,
  /// jadi state diperlakukan sama seperti setelah [login].
  Future<void> verifyEmail(String email, String otp) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.verifyEmail(email, otp));
  }

  /// Verifikasi Guest (Saksi) via token magic link + OTP. Sukses membentuk
  /// sesi Guest sementara (1 hari), diperlakukan sama seperti [login].
  Future<void> verifyMagicLink({
    required String token,
    required String otp,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.verifyMagicLink(token: token, otp: otp),
    );
  }

  /// Muat ulang data user (dipanggil setelah edit profil/foto) supaya nama
  /// dan avatar yang tampil di seluruh app langsung ter-update tanpa perlu
  /// logout-login. Kegagalan diam-diam diabaikan — sesi tetap dipertahankan
  /// dengan data lama daripada melempar user keluar hanya karena refresh gagal.
  Future<void> refreshUser() async {
    try {
      final user = await _repository.getMe();
      if (user != null) state = AsyncValue.data(user);
    } catch (_) {
      // best-effort
    }
  }

  /// Atur secara langsung [UserEntity] di state auth (misal setelah edit profil).
  void setUser(UserEntity user) {
    state = AsyncValue.data(user);
  }

  /// Logout dan hapus sesi pengguna.
  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

/// State untuk alur registrasi (Pewaris/Ahli Waris) — terpisah dari
/// [authProvider] karena registrasi TIDAK langsung membentuk sesi
/// (akun baru non-aktif sampai verifikasi email berhasil).
class RegisterNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  RegisterNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> registerPewaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nik,
    required bool consentAgreed,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.registerPewaris(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        nik: nik,
        consentAgreed: consentAgreed,
      ),
    );
  }

  Future<void> registerAhliWaris({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String invitationCode,
    required bool consentAgreed,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.registerAhliWaris(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        invitationCode: invitationCode,
        consentAgreed: consentAgreed,
      ),
    );
  }

  Future<void> resendOtp(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.resendOtp(email));
  }

  void reset() => state = const AsyncValue.data(null);
}

final registerProvider =
    StateNotifierProvider.autoDispose<RegisterNotifier, AsyncValue<void>>((
      ref,
    ) {
      return RegisterNotifier(ref.watch(authRepositoryProvider));
    });

/// State untuk alur Lupa Password (forgot + reset) — terpisah dari
/// [authProvider] karena tidak membentuk sesi.
class ForgotPasswordNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository _repository;
  ForgotPasswordNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> submit(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.forgotPassword(email));
  }
}

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordNotifier, AsyncValue<String?>>((
      ref,
    ) {
      return ForgotPasswordNotifier(ref.watch(authRepositoryProvider));
    });

class ResetPasswordNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository _repository;
  ResetPasswordNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> submit({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      ),
    );
  }
}

final resetPasswordProvider =
    StateNotifierProvider.autoDispose<ResetPasswordNotifier, AsyncValue<String?>>((
      ref,
    ) {
      return ResetPasswordNotifier(ref.watch(authRepositoryProvider));
    });

/// Provider utama untuk state autentikasi.
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });
