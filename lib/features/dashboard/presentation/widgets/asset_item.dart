import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/screens/allocate_asset_screen.dart';
import 'package:wt_mobile/features/assets/presentation/utils/asset_status_style.dart';

class AssetItem extends StatelessWidget {
  final AssetEntity asset;
  final bool isRevealed;
  const AssetItem({super.key, required this.asset, required this.isRevealed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final identifier = asset.accountIdentifier.isEmpty
        ? '••••••••'
        : asset.accountIdentifier;
    final allocatedPercentage = asset.allocations.fold<double>(
      0,
      (sum, a) => sum + a.percentage,
    );
    final heirCount = asset.allocations.length;

    return WtSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AllocateAssetScreen(asset: asset),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border.all(
                    color: isDark ? AppColors.gray700 : AppColors.gray200,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  asset.type.icon,
                  size: 20,
                  color: isDark ? Colors.white70 : AppColors.gray700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assetName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      asset.inheritanceScheme != null
                          ? '${asset.type.displayName} · Skema ${asset.inheritanceScheme!.displayName}'
                          : asset.type.displayName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isRevealed
                          ? Text(
                              identifier,
                              key: const ValueKey('open'),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : ImageFiltered(
                              key: const ValueKey('masked'),
                              imageFilter: ImageFilter.blur(
                                sigmaX: 6,
                                sigmaY: 6,
                              ),
                              child: Text(
                                identifier,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRevealed ? Icons.lock_open : Icons.lock,
                          size: 13,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isRevealed ? 'Terbuka' : 'Terenkripsi',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: allocatedPercentage >= 100
                  ? AppColors.success.withValues(alpha: 0.1)
                  : (isDark ? AppColors.darkSurface : AppColors.gray100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  heirCount == 0
                      ? Icons.person_add_alt_1_outlined
                      : Icons.groups_outlined,
                  size: 13,
                  color: allocatedPercentage >= 100
                      ? AppColors.success
                      : AppColors.gray500,
                ),
                const SizedBox(width: 5),
                Text(
                  heirCount == 0
                      ? 'Belum dialokasikan'
                      : '${allocatedPercentage.toStringAsFixed(0)}% · $heirCount ahli waris',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: allocatedPercentage >= 100
                        ? AppColors.success
                        : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
