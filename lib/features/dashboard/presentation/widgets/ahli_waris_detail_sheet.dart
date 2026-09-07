import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

/// Buka detail satu Ahli Waris (nama, hubungan, status, dokumen pendukung)
/// dari mana pun — avatar di Beranda, kartu undangan yang sudah dipakai, dsb.
/// Pewaris sebelumnya tidak punya cara melihat SIAPA pemilik satu relasi/
/// undangan selain menebak dari deskripsi hubungan.
Future<void> showAhliWarisDetail(
  BuildContext context,
  Map<String, dynamic> member,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AhliWarisDetailSheet(member: member),
  );
}

class AhliWarisDetailSheet extends ConsumerWidget {
  final Map<String, dynamic> member;
  const AhliWarisDetailSheet({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = member['id']?.toString() ?? '';
    final name = (member['ahliWarisName']?.toString().isNotEmpty ?? false)
        ? member['ahliWarisName'].toString()
        : 'Ahli Waris';
    final relation =
        (member['relationshipDescription']?.toString().isNotEmpty ?? false)
        ? member['relationshipDescription'].toString()
        : 'Hubungan belum diisi';
    final relationshipType = member['relationshipType']?.toString() ?? 'NASAB';
    final status = member['status']?.toString() ?? '';
    final documentUrl = member['supportingDocumentUrl']?.toString();
    final createdAt = DateTime.tryParse(member['createdAt']?.toString() ?? '');
    final canConfirm = status == 'PENDING_CONFIRMATION';
    final confirmState = ref.watch(confirmMemberProvider);

    return SafeArea(
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.gray200,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.gray900,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                WtStatusBadge(
                  label: _statusLabel(status),
                  color: _statusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.family_restroom_outlined,
              label: 'Jenis Hubungan',
              value: relationshipType == 'NON_NASAB'
                  ? 'Non-Nasab (butuh verifikasi Notaris)'
                  : 'Nasab',
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.event_outlined,
                label: 'Terdaftar Sejak',
                value: '${createdAt.day}/${createdAt.month}/${createdAt.year}',
              ),
            ],
            if (documentUrl != null && documentUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showDocumentUrl(context, documentUrl),
                borderRadius: BorderRadius.circular(12),
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
                        size: 18,
                        color: (isDark ? Colors.white : AppColors.navy)
                            .withValues(alpha: 0.5),
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
              ),
            ],
            if (canConfirm) ...[
              const SizedBox(height: 20),
              if (confirmState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WtErrorBanner(message: confirmState.error.toString()),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: confirmState.isLoading
                      ? null
                      : () async {
                          await ref
                              .read(confirmMemberProvider.notifier)
                              .confirm(id);
                          if (!context.mounted) return;
                          if (!ref.read(confirmMemberProvider).hasError) {
                            Navigator.pop(context);
                            WtSnackbar.success(
                              context,
                              'Hubungan keluarga dikonfirmasi.',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: confirmState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Konfirmasi Hubungan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ],
        ),
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

  String _statusLabel(String status) {
    switch (status) {
      case 'VERIFIED':
        return 'Aktif';
      case 'PENDING_CONFIRMATION':
        return 'Menunggu Konfirmasi';
      case 'PENDING_VERIFICATION':
        return 'Menunggu Notaris';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'VERIFIED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.danger;
      default:
        return AppColors.amber;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
