import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

class AhliWarisHeader extends StatelessWidget {
  final String userName;
  final bool isExecutor;
  const AhliWarisHeader({
    super.key,
    required this.userName,
    required this.isExecutor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELAMAT DATANG',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.navy.withValues(alpha: 0.7),
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (isExecutor) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Eksekutor',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              'Ahli Waris Terdaftar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppColors.navy.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AccessStatusBanner extends StatelessWidget {
  final AsyncValue<List<AssetEntity>> assetsAsync;
  const AccessStatusBanner({super.key, required this.assetsAsync});

  @override
  Widget build(BuildContext context) {
    return assetsAsync.when(
      loading: () => const WtInfoCard(
        icon: Icons.hourglass_empty,
        iconColor: AppColors.amber,
        title: 'Memuat Status...',
        description: 'Mengambil status akses brankas dari server.',
        padding: EdgeInsets.all(24),
      ),
      error: (_, _) => const WtInfoCard(
        icon: Icons.error_outline,
        iconColor: AppColors.danger,
        title: 'Gagal Memuat Status',
        description:
            'Tidak dapat mengambil status akses brankas. Periksa koneksi Anda.',
        padding: EdgeInsets.all(24),
      ),
      data: (assets) {
        final anyOpenable = assets.any(
          (a) =>
              a.status == AssetStatus.unlocked ||
              a.status == AssetStatus.liquidating ||
              a.status == AssetStatus.distributed,
        );
        if (assets.isEmpty) {
          return const WtInfoCard(
            icon: Icons.lock_clock,
            iconColor: AppColors.amber,
            title: 'Belum Ada Aset Teralokasi',
            description: 'Brankas warisan akan tersedia di sini setelah Pewaris mengalokasikan aset kepada Anda dan proses verifikasi kematian selesai.',
            padding: EdgeInsets.all(24),
          );
        }
        if (anyOpenable) {
          return const WtInfoCard(
            icon: Icons.lock_open,
            iconColor: AppColors.success,
            title: 'Akses Tersedia',
            description: 'Satu atau lebih aset sudah dapat diakses. Buka tab Brankas untuk melanjutkan.',
            padding: EdgeInsets.all(24),
            tinted: true,
          );
        }
        return const WtInfoCard(
          icon: Icons.lock_clock,
          iconColor: AppColors.amber,
          title: 'Akses Terkunci',
          description: 'Brankas warisan Anda saat ini dalam masa tunggu. Verifikasi hukum (Akta Kematian & persetujuan Saksi) diperlukan sebelum kunci enkripsi dilepas.',
          padding: EdgeInsets.all(24),
          tinted: true,
        );
      },
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isPrimary;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.sub,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isPrimary
        ? AppColors.primary
        : (isDark ? AppColors.darkSurface : AppColors.surface);
    final fgColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.white : AppColors.navy);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isPrimary ? Colors.white : fgColor).withValues(
                  alpha: isPrimary ? 0.2 : 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : fgColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: fgColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                color: fgColor.withValues(
                  alpha: isPrimary ? 0.7 : (isDark ? 0.4 : 0.6),
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PewarisInfoCard extends ConsumerWidget {
  const PewarisInfoCard({super.key});

  String _statusLabel(String? status) {
    switch (status) {
      case 'VERIFIED':
        return 'Terverifikasi';
      case 'PENDING_VERIFICATION':
        return 'Menunggu Verifikasi';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return 'Menunggu Konfirmasi';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'VERIFIED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.danger;
      default:
        return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync = ref.watch(myFamilyMembershipProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return membershipAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) =>
          Text(e.toString(), style: const TextStyle(color: AppColors.danger)),
      data: (items) {
        final entries = items.whereType<Map<String, dynamic>>().toList();
        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Belum ada data Pewaris terhubung.',
              style: TextStyle(color: AppColors.gray500),
            ),
          );
        }
        return Column(
          children: entries.map((m) {
            final name = m['pewarisName']?.toString();
            final relation = m['relationshipDescription']?.toString() ?? '-';
            final status = m['status']?.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WtSurfaceCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : AppColors.navy)
                            .withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (name != null && name.isNotEmpty)
                            ? name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? 'Nama tidak tersedia',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            relation,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : AppColors.navy.withValues(alpha: 0.7),
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
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
