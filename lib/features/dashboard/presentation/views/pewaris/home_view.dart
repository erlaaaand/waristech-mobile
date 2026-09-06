import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/proof_of_life/presentation/providers/proof_of_life_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/home_components.dart';

class PewarisHomeView extends ConsumerWidget {
  final VoidCallback onOpenAssets;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenHeirs;

  const PewarisHomeView({
    super.key,
    required this.onOpenAssets,
    required this.onOpenProfile,
    required this.onOpenHeirs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = ref.watch(authProvider).value?.name ?? 'Pengguna';
    final assetsAsync = ref.watch(myAssetsProvider);
    final checkInState = ref.watch(checkInProvider);

    ref.listen<AsyncValue<DateTime?>>(checkInProvider, (previous, next) {
      next.whenOrNull(
        data: (timestamp) {
          if (timestamp == null) return;
          WtSnackbar.success(
            context,
            'Konfirmasi Kehadiran berhasil dicatat.',
            backgroundColor: AppColors.success,
          );
        },
        error: (e, _) => WtSnackbar.error(context, e.toString()),
      );
    });

    return Container(
      decoration: BoxDecoration(
        // Light: kanvas abu premium. Dark: hitam scaffold — dulu selalu
        // gray50 di kedua tema, jadi tab ini tetap terang saat dark mode
        color: isDark ? AppColors.darkBackground : AppColors.background,
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: onOpenProfile,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.gray200,
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.gray900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good morning,',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : AppColors.gray500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.gray900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : AppColors.gray100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : AppColors.gray700,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Hero Card (Saved Assets) — kartu gelap premium yang
                    // SENGAJA tidak ikut tema (gradasi gelap + teks putih
                    // sendiri, tampil sama baik di light maupun dark mode).
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SavedAssetsHeroCard(
                        assetsAsync: assetsAsync,
                        onOpenAssets: onOpenAssets,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3. Quick Actions
                    QuickActionsRow(
                      onOpenAssets: onOpenAssets,
                      onOpenHeirs: onOpenHeirs,
                      onCheckIn: () {
                        if (!checkInState.isLoading) {
                          ref.read(checkInProvider.notifier).checkIn();
                        }
                      },
                    ),

                    const SizedBox(height: 40),

                    // 4. Ahli Waris (Quick Send Replacement)
                    AhliWarisSection(onOpenHeirs: onOpenHeirs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
