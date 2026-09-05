import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/compliance/presentation/providers/compliance_provider.dart';

/// Status persetujuan pemrosesan data pribadi — GET/POST /compliance/consent.
/// UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi.
class ConsentStatusScreen extends ConsumerWidget {
  const ConsentStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentAsync = ref.watch(myConsentProvider);
    final grantState = ref.watch(grantConsentProvider);

    ref.listen<AsyncValue<void>>(grantConsentProvider, (previous, next) {
      if (next.hasError) {
        WtSnackbar.error(context, next.error.toString());
      } else if (previous is AsyncLoading && next.hasValue) {
        WtSnackbar.success(context, 'Persetujuan berhasil diperbarui.');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Persetujuan Data Pribadi')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: consentAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                e.toString(),
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
            data: (consent) {
              final hasGivenConsent =
                  consent['hasGivenConsent'] as bool? ?? false;
              final consentGivenAt = consent['consentGivenAt']?.toString();
              final consentVersion = consent['consentVersion']?.toString();
              final currentPolicyVersion = consent['currentPolicyVersion']
                  ?.toString();
              final isUpToDate = consent['isUpToDate'] as bool? ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isUpToDate ? AppColors.success : AppColors.amber)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isUpToDate
                              ? Icons.verified_user
                              : Icons.warning_amber_rounded,
                          color: isUpToDate
                              ? AppColors.success
                              : AppColors.amber,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isUpToDate
                                ? 'Persetujuan Anda sudah sesuai kebijakan privasi terbaru.'
                                : hasGivenConsent
                                ? 'Kebijakan privasi telah diperbarui — persetujuan ulang diperlukan.'
                                : 'Anda belum memberikan persetujuan pemrosesan data pribadi.',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (hasGivenConsent) ...[
                    _InfoRow('Diberikan pada', consentGivenAt ?? '-'),
                    _InfoRow('Versi disetujui', consentVersion ?? '-'),
                  ],
                  _InfoRow(
                    'Versi kebijakan saat ini',
                    currentPolicyVersion ?? '-',
                  ),
                  const SizedBox(height: 24),
                  if (!isUpToDate)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: grantState.isLoading
                            ? null
                            : () => ref
                                  .read(grantConsentProvider.notifier)
                                  .grant(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: grantState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Setujui Kebijakan Terbaru'),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Baris "label — nilai" pada ringkasan persetujuan.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    // Kedua sisi Expanded (bukan SizedBox lebar tetap) — supaya tidak
    // RenderFlex overflow saat window menyempit drastis (mis. mode jendela
    // mengambang Android).
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
