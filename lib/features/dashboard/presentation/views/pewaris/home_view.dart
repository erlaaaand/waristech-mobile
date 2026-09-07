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
  final VoidCallback onOpenProtocol;

  const PewarisHomeView({
    super.key,
    required this.onOpenAssets,
    required this.onOpenProfile,
    required this.onOpenHeirs,
    required this.onOpenProtocol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = ref.watch(authProvider).value?.name ?? 'Pengguna';
    final assetsAsync = ref.watch(myAssetsProvider);
    final statusAsync = ref.watch(proofOfLifeStatusProvider);
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
                      child: DashboardHomeHeader(
                        userName: userName,
                        onOpenProfile: onOpenProfile,
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
                      onOpenProtocol: onOpenProtocol,
                      onOpenProfile: onOpenProfile,
                    ),

                    const SizedBox(height: 24),

                    // 4. Proof of Life Card
                    ProofOfLifeCard(
                      statusState: statusAsync,
                      isLoading: checkInState.isLoading,
                      onCheckIn: () {
                        if (!checkInState.isLoading) {
                          ref.read(checkInProvider.notifier).checkIn();
                        }
                      },
                    ),

                    const SizedBox(height: 32),

                    // 5. Ahli Waris (Quick Send Replacement)
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
