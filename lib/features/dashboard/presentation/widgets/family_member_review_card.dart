import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/asset_verification_card.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

/// Kartu tinjauan satu relasi keluarga Non-Nasab — (NOTARIS) memutuskan
/// Verify/Reject berdasarkan `supportingDocumentUrl` yang diajukan Pewaris.
/// Reuse [ActionButton]/[InitialAvatar]/[DoneCard] dari kartu verifikasi aset
/// supaya gaya tombol setuju/tolak konsisten di seluruh Portal Notaris.
class FamilyMemberReviewCard extends ConsumerWidget {
  final Map<String, dynamic> member;

  const FamilyMemberReviewCard({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = member['id']?.toString() ?? '';
    final relation = (member['relationshipDescription']?.toString().isNotEmpty ?? false)
        ? member['relationshipDescription'].toString()
        : 'Hubungan belum diisi';
    final name = (member['ahliWarisName']?.toString().isNotEmpty ?? false)
        ? member['ahliWarisName'].toString()
        : 'Ahli Waris';
    final documentUrl = member['supportingDocumentUrl']?.toString();
    final actionState = ref.watch(familyMemberActionProvider(id));

    if (actionState.isDone) {
      return DoneCard(assetName: relation, isDark: isDark);
    }

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
              InitialAvatar(initial: name[0].toUpperCase()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$relation · Non-Nasab',
                      style: const TextStyle(fontSize: 12, color: AppColors.gray500),
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
                        'Lihat Dokumen Pendukung',
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
              message: 'Pewaris belum melampirkan dokumen pendukung.',
              padding: EdgeInsets.all(12),
              borderRadius: 12,
              iconSize: 16,
              textStyle: TextStyle(fontSize: 12),
            ),
          if (actionState.error != null) ...[
            const SizedBox(height: 12),
            WtErrorBanner(
              message: actionState.error!,
              padding: const EdgeInsets.all(12),
              borderRadius: 12,
              iconSize: 16,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Tolak',
                  color: AppColors.danger,
                  isLoading: actionState.isLoading,
                  onPressed: () => _showRejectDialog(context, ref, id, relation),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  label: 'Setujui',
                  color: AppColors.primary,
                  isPrimary: true,
                  isLoading: actionState.isLoading,
                  onPressed: () =>
                      ref.read(familyMemberActionProvider(id).notifier).verify(id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDocumentUrl(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dokumen Pendukung'),
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

  Future<void> _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String relation,
  ) async {
    final confirmed = await WtConfirmDialog.show(
      context,
      title: 'Tolak Relasi Keluarga',
      message:
          'Apakah Anda yakin ingin menolak relasi "$relation"?\nPewaris akan mendapat notifikasi.',
      confirmLabel: 'Ya, Tolak',
      confirmColor: AppColors.danger,
    );

    if (confirmed && context.mounted) {
      ref.read(familyMemberActionProvider(id).notifier).reject(id);
    }
  }
}
