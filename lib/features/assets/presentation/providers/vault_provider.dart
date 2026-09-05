import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/crypto/shamir_secret_sharing.dart';
import 'package:wt_mobile/core/storage/secure_key_share_storage.dart';
import 'package:wt_mobile/features/assets/domain/entities/vault_secret_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';

/// Orkestrasi pembukaan brankas SUNGGUHAN — menggantikan simulasi
/// `Future.delayed` yang sebelumnya ada di `brankas_view.dart`.
///
/// Alurnya SENGAJA tidak pernah meminta server merekonstruksi apa pun:
/// 1. Ambil `systemShare` dari `GET /assets/:id/secret` (bagian server).
/// 2. Ambil bagian Eksekutor dari secure storage LOKAL (Fase 2).
/// 3. Gabungkan keduanya dengan [ShamirSecretSharing.combine] di perangkat ini.
/// 4. `jsonDecode` hasilnya menjadi kredensial.
///
/// Kredensial hasil rekonstruksi TIDAK PERNAH melintasi jaringan.
final vaultUnlockProvider = FutureProvider.autoDispose
    .family<VaultSecretEntity, String>((ref, assetId) async {
      final repo = ref.watch(assetRepositoryProvider);
      final unlockResult = await repo.unlockAsset(assetId);

      if (!unlockResult.isExecutor) {
        throw Exception(
          'Hanya Eksekutor yang ditunjuk yang dapat membuka bagian kunci aset ini.',
        );
      }

      final systemShare = unlockResult.systemShare;
      if (systemShare == null || systemShare.isEmpty) {
        throw Exception(
          'Server belum menyediakan bagian kunci SYSTEM — aset mungkin belum bermigrasi ke Secret Sharing.',
        );
      }

      final executorShare = await SecureKeyShareStorage.readExecutorShare(
        assetId,
      );
      if (executorShare == null || executorShare.isEmpty) {
        throw const MissingExecutorShareException();
      }

      final combinedHex = ShamirSecretSharing.combine([
        systemShare,
        executorShare,
      ]);
      final plaintext = ShamirSecretSharing.hex2str(combinedHex);
      final decoded = jsonDecode(plaintext) as Map<String, dynamic>;
      return VaultSecretEntity.fromJson(decoded);
    });
