import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/users/presentation/providers/user_provider.dart';

/// (Notaris) Generate keypair RSA-2048 & daftarkan public key —
/// POST /users/me/public-key. Keypair dibuat DI PERANGKAT INI; private key
/// TIDAK PERNAH dikirim ke server, hanya tersimpan di flutter_secure_storage.
class NotarisPublicKeyScreen extends ConsumerWidget {
  const NotarisPublicKeyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasKeyAsync = ref.watch(hasNotarisKeypairProvider);
    final registerState = ref.watch(registerNotarisKeyProvider);

    ref.listen<AsyncValue<void>>(registerNotarisKeyProvider, (previous, next) {
      if (next.hasError) {
        WtSnackbar.error(context, next.error.toString());
      } else if (previous is AsyncLoading && next.hasValue) {
        WtSnackbar.success(
          context,
          'Keypair berhasil dibuat & public key terdaftar.',
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Kunci Enkripsi (PKI)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Sebagai Notaris, Anda menitipkan salinan bagian kunci aset '
                  '(terenkripsi) dari para Pewaris. Keypair RSA dibuat DI PERANGKAT '
                  'INI — private key tidak pernah meninggalkan perangkat Anda. '
                  'Kehilangan perangkat ini berarti kehilangan akses ke seluruh '
                  'titipan yang pernah dienkripsi dengan kunci ini.',
                  style: TextStyle(fontSize: 12.5, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              hasKeyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  e.toString(),
                  style: const TextStyle(color: AppColors.danger),
                ),
                data: (hasKey) => hasKey
                    ? const _AlreadyRegisteredCard()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: registerState.isLoading
                              ? null
                              : () => _confirmAndGenerate(context, ref),
                          icon: registerState.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.vpn_key),
                          label: const Text('Buat & Daftarkan Kunci'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndGenerate(BuildContext context, WidgetRef ref) async {
    final confirmed = await WtConfirmDialog.show(
      context,
      title: 'Buat Keypair Baru?',
      message:
          'Bila sebelumnya Anda pernah membuat keypair di perangkat lain, '
          'tindakan ini TIDAK menggantikannya di server (masih keypair lama '
          'yang terdaftar) kecuali Anda melanjutkan. Pastikan ini perangkat '
          'utama Anda sebagai Notaris.',
      confirmLabel: 'Lanjutkan',
    );
    if (confirmed) {
      ref.read(registerNotarisKeyProvider.notifier).generateAndRegister();
    }
  }
}

class _AlreadyRegisteredCard extends StatelessWidget {
  const _AlreadyRegisteredCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Keypair sudah terdaftar di perangkat ini.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
