import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/aset_list_header.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/asset_item.dart';

class PewarisAsetView extends ConsumerStatefulWidget {
  const PewarisAsetView({super.key});

  @override
  ConsumerState<PewarisAsetView> createState() => _PewarisAsetViewState();
}

class _PewarisAsetViewState extends ConsumerState<PewarisAsetView> {
  String _query = '';
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(myAssetsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            onPressed: () => context.pushNamed('create-asset'),
            backgroundColor: isDark ? Colors.white : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add, size: 24),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VaultHeader(
                  isRevealed: _revealed,
                  onToggle: () => setState(() => _revealed = !_revealed),
                ),
                const MaskInfoBanner(),
                const SizedBox(height: 14),
                SearchField(onChanged: (v) => setState(() => _query = v)),
                const SizedBox(height: 14),
              ],
            ),
          ),
          assetsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: WtErrorBanner(
                message: err.toString(),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                borderRadius: 12,
                iconSize: 20,
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
            data: (assets) {
              final filtered = _query.isEmpty
                  ? assets
                  : assets
                        .where(
                          (a) =>
                              a.assetName.toLowerCase().contains(_query) ||
                              a.platform.toLowerCase().contains(_query) ||
                              a.type.displayName.toLowerCase().contains(_query),
                        )
                        .toList();
              if (filtered.isEmpty) {
                return const SliverToBoxAdapter(
                  child: WtEmptyState(
                    message: 'Belum ada aset terdaftar.',
                    icon: Icons.inventory_2_outlined,
                    iconSize: 44,
                    iconColor: AppColors.gray300,
                    padding: EdgeInsets.all(40),
                    messageStyle: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      AssetItem(asset: filtered[i], isRevealed: _revealed),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
