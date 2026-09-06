import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

class SavedAssetsHeroCard extends StatelessWidget {
  final AsyncValue<List<AssetEntity>> assetsAsync;
  final VoidCallback onOpenAssets;

  const SavedAssetsHeroCard({
    super.key,
    required this.assetsAsync,
    required this.onOpenAssets,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenAssets,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.gray900,
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            colors: [AppColors.primaryDark, AppColors.primaryDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MY ASSETS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Icon(
                  Icons.shield_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            assetsAsync.when(
              loading: () => const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              ),
              error: (err, _) => SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    err.toString(),
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
              data: (assets) {
                if (assets.isEmpty) {
                  return const SizedBox(
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belum ada aset tersimpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ketuk untuk mulai menyusun brankas Anda',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                final recentAsset = assets.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recentAsset.platform.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recentAsset.accountIdentifier.isNotEmpty
                          ? recentAsset.accountIdentifier
                          : recentAsset.assetName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Aset',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${assets.length} ASET',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onOpenAssets;
  final VoidCallback onOpenHeirs;
  final VoidCallback onCheckIn;

  const QuickActionsRow({
    super.key,
    required this.onOpenAssets,
    required this.onOpenHeirs,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Aset',
            onTap: onOpenAssets,
          ),
          _ActionItem(
            icon: Icons.people_outline,
            label: 'Ahli Waris',
            onTap: onOpenHeirs,
          ),
          _ActionItem(
            icon: Icons.fact_check_outlined,
            label: 'Check-In',
            onTap: onCheckIn,
          ),
          _ActionItem(icon: Icons.more_horiz, label: 'Lainnya', onTap: () {}),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDark ? Colors.white : AppColors.gray900),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}

class AhliWarisSection extends ConsumerWidget {
  final VoidCallback onOpenHeirs;

  const AhliWarisSection({super.key, required this.onOpenHeirs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final familyAsync = ref.watch(familyMembersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ahli Waris',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
              GestureDetector(
                onTap: onOpenHeirs,
                child: Text(
                  'Lihat semua >',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        familyAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: CircularProgressIndicator(),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              err.toString(),
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
          data: (members) {
            if (members.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: onOpenHeirs,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.gray100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add_alt_1_outlined,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.gray500,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Belum ada ahli waris',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: members.map((member) {
                  final name = member['full_name'] as String? ?? 'A';
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.gray200,
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
                        const SizedBox(height: 8),
                        Text(
                          name.split(' ').first,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppColors.gray700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
