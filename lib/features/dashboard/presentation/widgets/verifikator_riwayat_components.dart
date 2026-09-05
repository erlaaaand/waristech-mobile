import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';

class HistoryCard extends StatelessWidget {
  final AssetEntity asset;
  const HistoryCard({super.key, required this.asset});

  (Color, String) _statusMeta(AssetStatus status) {
    switch (status) {
      case AssetStatus.verified:
        return (AppColors.success, 'Disetujui');
      case AssetStatus.rejected:
        return (AppColors.danger, 'Ditolak');
      case AssetStatus.closed:
        return (AppColors.gray500, 'Ditutup');
      default:
        return (AppColors.amber, status.displayLabel);
    }
  }

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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (statusColor, statusLabel) = _statusMeta(asset.status);

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
              WtStatusBadge(label: statusLabel, color: statusColor),
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
            'Diverifikasi pada: ${_formatDate(asset.verifiedAt)}',
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
