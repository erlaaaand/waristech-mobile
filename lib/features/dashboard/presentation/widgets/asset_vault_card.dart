import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/assets/presentation/screens/asset_guidance_screen.dart';
import 'package:wt_mobile/features/assets/presentation/screens/liquidation_upload_screen.dart';
import 'package:wt_mobile/features/assets/presentation/utils/asset_status_style.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/vault_unlock_sheet.dart';

AssetAllocationEntity? findMyAllocation(AssetEntity asset, String? userId) {
  if (userId == null) return null;
  for (final a in asset.allocations) {
    if (a.ahliWarisId == userId) return a;
  }
  return null;
}

void openVaultSheet(BuildContext context, AssetEntity asset) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => VaultUnlockSheet(asset: asset),
  );
}

class AssetVaultCard extends ConsumerWidget {
  final AssetEntity asset;
  final String? currentUserId;
  const AssetVaultCard({
    super.key,
    required this.asset,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myAllocation = findMyAllocation(asset, currentUserId);
    final isExecutor = myAllocation?.isExecutor ?? false;
    final canOpenVault =
        asset.isVaultCustody &&
        isExecutor &&
        (asset.status == AssetStatus.unlocked ||
            asset.status == AssetStatus.liquidating);

    return WtSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assetName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${asset.type.displayName} • ${asset.platform}${myAllocation != null ? ' • ${myAllocation.percentage.toStringAsFixed(0)}%' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isDark ? Colors.white : AppColors.navy)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              WtStatusBadge(
                label: asset.status.displayLabel,
                color: asset.status.color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isExecutor)
            const WtStatusBadge(
              label: 'Anda Eksekutor',
              color: AppColors.primary,
            ),
          const SizedBox(height: 12),
          _AssetActionArea(
            asset: asset,
            isExecutor: isExecutor,
            canOpenVault: canOpenVault,
            myAllocation: myAllocation,
          ),
        ],
      ),
    );
  }
}

/// Area tombol aksi pada kartu aset — isinya bergantung pada jenis kustodi,
/// status aset, dan apakah pengguna adalah Eksekutor.
class _AssetActionArea extends ConsumerWidget {
  final AssetEntity asset;
  final bool isExecutor;
  final bool canOpenVault;
  final AssetAllocationEntity? myAllocation;

  const _AssetActionArea({
    required this.asset,
    required this.isExecutor,
    required this.canOpenVault,
    required this.myAllocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!asset.isVaultCustody) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AssetGuidanceScreen(
                assetName: asset.assetName,
                assetId: asset.id,
              ),
            ),
          ),
          icon: const Icon(Icons.menu_book_outlined, size: 18),
          label: const Text(
            'Lihat Panduan Proses Resmi',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    }

    if (isExecutor && asset.status == AssetStatus.unlocked) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => openVaultSheet(context, asset),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              icon: const Icon(Icons.lock_open, size: 18),
              label: const Text('Buka Brankas'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LiquidationUploadScreen(
                    assetId: asset.id,
                    assetName: asset.assetName,
                  ),
                ),
              ),
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text(
                'Unggah Bukti Pencairan',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      );
    }

    if (canOpenVault) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => openVaultSheet(context, asset),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          icon: const Icon(Icons.lock_open, size: 18),
          label: const Text('Buka Brankas'),
        ),
      );
    }

    // Disalin ke variabel lokal supaya bisa di-promote — field kelas yang
    // nullable tidak ikut ter-promote oleh pengecekan `!= null`.
    final allocation = myAllocation;
    if (!isExecutor &&
        asset.status == AssetStatus.distributed &&
        allocation != null &&
        allocation.acknowledgedAt == null) {
      final ackState = ref.watch(acknowledgeDistributionProvider(asset.id));
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: ackState.isLoading
              ? null
              : () => ref
                    .read(acknowledgeDistributionProvider(asset.id).notifier)
                    .acknowledge(asset.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          icon: ackState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_circle_outline, size: 18),
          label: const Text(
            'Konfirmasi Penerimaan Dana',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    }

    if (!isExecutor &&
        asset.status == AssetStatus.distributed &&
        myAllocation?.acknowledgedAt != null) {
      return const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 16),
          SizedBox(width: 6),
          Text(
            'Penerimaan dana telah dikonfirmasi.',
            style: TextStyle(fontSize: 12.5, color: AppColors.success),
          ),
        ],
      );
    }

    return Text(
      _statusMessage(asset.status, isExecutor: isExecutor),
      style: const TextStyle(fontSize: 12.5, color: AppColors.gray600, height: 1.4),
    );
  }

  /// Keterangan yang relevan dengan TAHAP aset saat ini. Dulu Ahli Waris
  /// non-eksekutor selalu melihat "Eksekutor bertanggung jawab mencairkan…"
  /// bahkan saat Pewaris masih hidup atau kasusnya sudah ditutup.
  String _statusMessage(AssetStatus status, {required bool isExecutor}) {
    switch (status) {
      case AssetStatus.pendingVerification:
        return 'Aset masih menunggu verifikasi Notaris. Pewaris masih dapat mengubah alokasinya.';
      case AssetStatus.verified:
        return 'Aset sudah terverifikasi Notaris. Brankas baru dapat dibuka setelah verifikasi kematian Pewaris selesai.';
      case AssetStatus.rejected:
        return 'Aset ditolak Notaris saat verifikasi dan menunggu perbaikan dari Pewaris.';
      case AssetStatus.pendingCooldown:
        return 'Masa tunda 14 hari sedang berjalan. Brankas terbuka otomatis bila tidak ada sanggahan.';
      case AssetStatus.frozen:
        return 'Aset dibekukan karena ada sanggahan saksi — menunggu keputusan Notaris.';
      case AssetStatus.disputedLiquidation:
        return 'Pencairan aset disengketakan dan sedang ditinjau Notaris.';
      case AssetStatus.unlocked:
      case AssetStatus.liquidating:
        return isExecutor
            ? 'Bukti pencairan sudah dikirim dan menunggu tinjauan Notaris.'
            : 'Eksekutor sedang mencairkan aset ini dan akan mendistribusikan bagian Anda.';
      case AssetStatus.distributed:
        return isExecutor
            ? 'Dana telah didistribusikan. Menunggu konfirmasi penerimaan dari ahli waris lain.'
            : 'Dana telah didistribusikan.';
      case AssetStatus.closed:
        return 'Kasus ditutup Notaris. Data rahasia aset telah dihancurkan.';
    }
  }
}
