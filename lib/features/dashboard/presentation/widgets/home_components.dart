import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/proof_of_life/domain/entities/proof_of_life_status_entity.dart';

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
      child: AspectRatio(
        aspectRatio: 1.586, // Standar rasio credit card
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryDeep,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDeep.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Efek pantulan cahaya (glassmorphism highlight)
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section: Logo and Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip icon
                      Container(
                        width: 42,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightest.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primaryLightest.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.sim_card,
                          color: AppColors.primaryLightest.withValues(alpha: 0.8),
                          size: 20,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'WARISTECH',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Middle section: Data
                  assetsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        err.toString(),
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                    data: (assets) {
                      if (assets.isEmpty) {
                        return const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NO ASSETS SECURED',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ketuk untuk tambah',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        );
                      }

                      final recentAsset = assets.first;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recentAsset.platform.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
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
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                  
                  // Bottom section: Footer info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL ASET',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          assetsAsync.maybeWhen(
                            data: (assets) => Text(
                              '${assets.length} ITEM SECURED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            orElse: () => const Text(
                              '0 ITEM SECURED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.contactless_outlined,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onOpenAssets;
  final VoidCallback onOpenHeirs;
  final VoidCallback onOpenProtocol;
  final VoidCallback onOpenProfile;

  const QuickActionsRow({
    super.key,
    required this.onOpenAssets,
    required this.onOpenHeirs,
    required this.onOpenProtocol,
    required this.onOpenProfile,
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
            label: 'Brankas',
            onTap: onOpenAssets,
          ),
          _ActionItem(
            icon: Icons.people_outline,
            label: 'Ahli Waris',
            onTap: onOpenHeirs,
          ),
          _ActionItem(
            icon: Icons.description_outlined,
            label: 'Protokol',
            onTap: onOpenProtocol,
          ),
          _ActionItem(
            icon: Icons.more_horiz,
            label: 'Lainnya',
            onTap: onOpenProfile,
          ),
        ],
      ),
    );
  }
}

class ProofOfLifeCard extends StatelessWidget {
  final AsyncValue<ProofOfLifeStatusEntity> statusState;
  final VoidCallback onCheckIn;
  final bool isLoading;

  const ProofOfLifeCard({
    super.key,
    required this.statusState,
    required this.onCheckIn,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = statusState.valueOrNull;
    final now = DateTime.now();
    final hasCheckedInToday = status != null &&
        status.lastCheckInAt.toLocal().year == now.year &&
        status.lastCheckInAt.toLocal().month == now.month &&
        status.lastCheckInAt.toLocal().day == now.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.primaryDeep : AppColors.primaryLightest.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightest.withValues(alpha: isDark ? 0.1 : 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  color: isDark ? AppColors.primaryLightest : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proof of Life (Kehadiran)',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.gray900,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    statusState.when(
                      data: (status) {
                        final date = status.lastCheckInAt.toLocal();
                        final daysLeft = status.daysUntilDue;
                        final isWarning = daysLeft <= 7;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terakhir: ${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              daysLeft > 0
                                  ? '$daysLeft hari tersisa untuk Check-in'
                                  : 'Sistem darurat akan segera diaktifkan!',
                              style: TextStyle(
                                color: daysLeft > 0
                                    ? (isWarning ? AppColors.danger : (isDark ? Colors.white70 : AppColors.gray600))
                                    : AppColors.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => Text('Memuat...', style: TextStyle(color: isDark ? Colors.white70 : AppColors.gray500, fontSize: 12)),
                      error: (err, stack) => const Text('Gagal memuat status', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Lakukan check-in setiap 30 hari agar sistem mendeteksi Anda aktif. Jika gagal check-in, protokol warisan darurat akan mulai dijalankan.',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.gray600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading || hasCheckedInToday ? null : onCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? AppColors.gray800 : AppColors.gray200,
                disabledForegroundColor: isDark ? Colors.white54 : AppColors.gray500,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      hasCheckedInToday ? 'Sudah Check-in Hari Ini' : 'Check-in Sekarang',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
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
                  final name =
                      (member['ahliWarisName'] as String?)?.trim().isNotEmpty ==
                              true
                          ? member['ahliWarisName'] as String
                          : (member['relationshipDescription'] as String?)
                                  ?.trim() ??
                              'Ahli Waris';
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
