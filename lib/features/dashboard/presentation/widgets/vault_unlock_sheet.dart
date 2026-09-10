import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/storage/secure_key_share_storage.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/utils/clipboard_utils.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/domain/entities/vault_secret_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/vault_provider.dart';
import 'package:wt_mobile/features/assets/presentation/screens/legal_fallback_screen.dart';

class VaultUnlockSheet extends ConsumerWidget {
  final AssetEntity asset;
  const VaultUnlockSheet({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockAsync = ref.watch(vaultUnlockProvider(asset.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkSurface : Colors.white).withValues(
              alpha: 0.72,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : AppColors.navy).withValues(
                  alpha: 0.12,
                ),
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vpn_key, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          asset.assetName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Shamir's Secret Sharing — digabung di perangkat ini",
                    style: TextStyle(fontSize: 11, color: AppColors.gray500),
                  ),
                  const SizedBox(height: 20),
                  unlockAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => _UnlockError(asset: asset, error: e),
                    data: (secret) => _UnlockedCredentials(secret),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tampilan kegagalan rekonstruksi kunci, lengkap dengan dua jalan keluar:
/// impor bagian kunci Eksekutor, atau ajukan jalur hukum konvensional.
class _UnlockError extends ConsumerWidget {
  final AssetEntity asset;
  final Object error;

  const _UnlockError({required this.asset, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMissingShare = error is MissingExecutorShareException;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WtErrorBanner(message: error.toString()),
        if (isMissingShare) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showImportShareDialog(context, ref),
              icon: const Icon(Icons.key, size: 18),
              label: const Text(
                'Impor Bagian Kunci Eksekutor',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LegalFallbackScreen(
                      assetId: asset.id,
                      assetName: asset.assetName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.gavel_outlined, size: 18),
              label: const Text(
                'Ajukan Jalur Hukum Konvensional',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showImportShareDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ctrl = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Impor Bagian Kunci Eksekutor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempel bagian kunci Eksekutor yang diberikan Pewaris (mis. lewat '
              'kanal aman). Nilai ini akan disimpan di perangkat ini.',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (value == null || value.isEmpty) return;
    await SecureKeyShareStorage.saveExecutorShare(asset.id, value);
    ref.invalidate(vaultUnlockProvider(asset.id));
  }
}

/// Daftar kredensial setelah kunci berhasil direkonstruksi.
class _UnlockedCredentials extends StatelessWidget {
  final VaultSecretEntity secret;

  const _UnlockedCredentials(this.secret);

  @override
  Widget build(BuildContext context) {
    if (secret.isEmpty) {
      return const Text(
        'Kunci berhasil direkonstruksi, namun Pewaris tidak menyimpan '
        'kredensial apa pun pada aset ini.',
        style: TextStyle(fontSize: 12.5, color: AppColors.gray600, height: 1.4),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (secret.username != null)
          _CredentialRow('Username', secret.username!),
        if (secret.password != null)
          _CredentialRow('Password', secret.password!, obscure: true),
        if (secret.pin != null)
          _CredentialRow('PIN', secret.pin!, obscure: true),
        if (secret.notes != null) _CredentialRow('Catatan', secret.notes!),
        for (final entry in secret.extras.entries)
          _CredentialRow(entry.key, entry.value),
      ],
    );
  }
}

/// Satu baris kredensial hasil dekripsi (label + nilai + tombol salin).
class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  final bool obscure;

  const _CredentialRow(this.label, this.value, {this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => copyToClipboard(context, value, label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
