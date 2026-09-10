import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/utils/asset_status_style.dart';

class HistoryCard extends StatelessWidget {
  final AssetEntity asset;
  const HistoryCard({super.key, required this.asset});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final local = dt.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  /// Aset yang ditolak tidak punya `verifiedAt` — dulu tetap ditulis
  /// "Diverifikasi pada: -". Tanggal yang relevan dipilih sesuai status.
  String get _dateLine {
    if (asset.status == AssetStatus.rejected) {
      return 'Ditolak pada: ${_formatDate(asset.updatedAt)}';
    }
    if (asset.verifiedAt != null) {
      return 'Diverifikasi pada: ${_formatDate(asset.verifiedAt)}';
    }
    return 'Diperbarui: ${_formatDate(asset.updatedAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = asset.status == AssetStatus.closed
        ? AppColors.gray500
        : asset.status.color;

    return WtSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  asset.assetName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              WtStatusBadge(
                label: asset.status.displayLabel,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${asset.type.displayName} • ${asset.platform}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppColors.navy.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _dateLine,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.navy.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
