import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/asset_vault_card.dart';

class AhliWarisBrankasView extends ConsumerWidget {
  const AhliWarisBrankasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(allocatedAssetsProvider);
    final currentUserId = ref.watch(authProvider).value?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtScreenHeader(label: 'Inventaris', title: 'Brankas Aset'),
          const SizedBox(height: 20),
          assetsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => WtErrorBanner(message: e.toString()),
            data: (assets) {
              if (assets.isEmpty) {
                return const WtEmptyState(
                  message: 'Belum ada aset yang teralokasi ke Anda.',
                  icon: Icons.inventory_2_outlined,
                );
              }
              return Column(
                children: assets
                    .map(
                      (asset) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AssetVaultCard(
                          asset: asset,
                          currentUserId: currentUserId,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
