import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/asset_verification_card.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';

/// Kartu tinjauan satu dokumen akta kematian di antrean Notaris — data dari
/// GET /inheritance/death-certificate/notaris/pending. Reuse
/// [ActionButton]/[InitialAvatar]/[DoneCard] dari kartu verifikasi aset agar
/// gaya tombol konsisten di seluruh Portal Notaris.
///
/// Backend hanya menyediakan aksi verify untuk resource ini (tidak ada
/// endpoint reject terpisah) — beda dengan verifikasi aset/relasi keluarga.
class DeathCertificateReviewCard extends ConsumerWidget {
  final Map<String, dynamic> item;

  const DeathCertificateReviewCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = item['id']?.toString() ?? '';
    final pewarisId = item['pewarisId']?.toString() ?? '-';
    final documentUrl = item['documentUrl']?.toString();
    final actionState = ref.watch(verifyDeathCertificateProvider(id));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : AppColors.navy).withValues(
            alpha: 0.05,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InitialAvatar(initial: 'P'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Akta Kematian',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pewaris: $pewarisId',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : AppColors.navy.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const WtStatusBadge(label: 'Menunggu', color: AppColors.amber),
            ],
          ),
          const SizedBox(height: 12),
          if (documentUrl != null && documentUrl.isNotEmpty)
            InkWell(
              onTap: () => _showDocumentUrl(context, documentUrl),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.warm,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: (isDark ? Colors.white : AppColors.navy)
                          .withValues(alpha: 0.4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Lihat Dokumen Akta Kematian',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 16),
                  ],
                ),
              ),
            )
          else
            const WtErrorBanner(
              message: 'Dokumen belum dilampirkan.',
              padding: EdgeInsets.all(12),
              borderRadius: 12,
              iconSize: 16,
              textStyle: TextStyle(fontSize: 12),
            ),
          if (actionState.hasError) ...[
            const SizedBox(height: 12),
            WtErrorBanner(
              message: actionState.error.toString(),
              padding: const EdgeInsets.all(12),
              borderRadius: 12,
              iconSize: 16,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: 'Verifikasi',
              color: AppColors.primary,
              isPrimary: true,
              isLoading: actionState.isLoading,
              onPressed: () =>
                  ref.read(verifyDeathCertificateProvider(id).notifier).verify(id),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentUrl(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dokumen Akta Kematian'),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
