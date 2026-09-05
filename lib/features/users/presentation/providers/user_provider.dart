import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/crypto/rsa_keypair_service.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/users/data/datasources/user_remote_data_source.dart';

final _ds = UserRemoteDataSource();

/// Notifier edit profil (nama & kata sandi) — PATCH /users/:id. Setelah
/// sukses, memuat ulang [authProvider] supaya nama baru langsung tampil.
class UpdateProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  UpdateProfileNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> update({
    required String userId,
    String? fullName,
    String? currentPassword,
    String? newPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ds.updateProfile(
        userId: userId,
        fullName: fullName,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    if (!state.hasError) await _ref.read(authProvider.notifier).refreshUser();
  }
}

final updateProfileProvider =
    StateNotifierProvider.autoDispose<UpdateProfileNotifier, AsyncValue<void>>(
      (ref) => UpdateProfileNotifier(ref),
    );

/// Notifier ganti foto profil — PATCH /users/me/avatar.
class UpdateAvatarNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  UpdateAvatarNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> update(String avatarUrl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.updateAvatar(avatarUrl));
    if (!state.hasError) await _ref.read(authProvider.notifier).refreshUser();
  }
}

final updateAvatarProvider =
    StateNotifierProvider.autoDispose<UpdateAvatarNotifier, AsyncValue<void>>(
      (ref) => UpdateAvatarNotifier(ref),
    );

/// Status keypair RSA Notaris di perangkat ini (true bila sudah pernah dibuat).
final hasNotarisKeypairProvider = FutureProvider.autoDispose<bool>((ref) {
  return RsaKeypairService.hasKeypair();
});

/// Notifier alur generate + daftarkan public key Notaris.
class RegisterNotarisKeyNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  RegisterNotarisKeyNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> generateAndRegister() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final keypair = await RsaKeypairService.generateKeypair();
      await _ds.registerPublicKey(keypair.publicKeyPem);
    });
    if (!state.hasError) _ref.invalidate(hasNotarisKeypairProvider);
  }
}

final registerNotarisKeyProvider =
    StateNotifierProvider.autoDispose<
      RegisterNotarisKeyNotifier,
      AsyncValue<void>
    >((ref) {
      return RegisterNotarisKeyNotifier(ref);
    });

/// Ambil public key Notaris tujuan (dipakai Pewaris untuk enkripsi share).
Future<Map<String, dynamic>> fetchNotarisPublicKey(String notarisId) {
  return _ds.getNotarisPublicKey(notarisId);
}
