import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';

/// Tab Aset untuk role Pewaris.
/// Menampilkan daftar aset dari backend dengan filter kategori.
class PewarisAsetView extends ConsumerStatefulWidget {
  const PewarisAsetView({super.key});

  @override
  ConsumerState<PewarisAsetView> createState() => _PewarisAsetViewState();
}

class _PewarisAsetViewState extends ConsumerState<PewarisAsetView> {
  String _selectedCategory = 'Semua';

  static const _categories = ['Semua', 'E-Wallet', 'Crypto', 'Bank', 'Sosial'];

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(myAssetsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WtSectionTitle('Inventarisasi'),
            const SizedBox(height: 4),
            const Text('Aset Digital', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            _SearchBar(),
            const SizedBox(height: 20),
            _CategoryFilter(
              categories: _categories,
              selected: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 20),
            _AssetList(assetsAsync: assetsAsync),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari aset...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryFilter({required this.categories, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isActive = cat == selected;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.navy : (isDark ? AppColors.darkSurface : AppColors.surface),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isActive ? Colors.white : (isDark ? Colors.white54 : AppColors.navy.withOpacity(0.8)),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AssetList extends StatelessWidget {
  final AsyncValue<List<AssetEntity>> assetsAsync;
  const _AssetList({required this.assetsAsync});

  @override
  Widget build(BuildContext context) {
    return assetsAsync.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
      ),
      error: (err, _) => _ErrorBanner(message: err.toString()),
      data: (assets) {
        if (assets.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _AssetCard(asset: assets[i]),
        );
      },
    );
  }
}

class _AssetCard extends StatelessWidget {
  final AssetEntity asset;
  const _AssetCard({required this.asset});

  static (IconData, Color) _iconForType(AssetType type) {
    switch (type) {
      case AssetType.crypto:   return (Icons.currency_bitcoin, AppColors.amber);
      case AssetType.bank:     return (Icons.account_balance, Colors.green);
      case AssetType.ewallet:  return (Icons.account_balance_wallet, const Color(0xFF00AED6));
      case AssetType.socialMedia: return (Icons.photo_camera, Colors.pink);
      case AssetType.other:    return (Icons.cloud, Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color) = _iconForType(asset.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.assetName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text('${asset.type.displayName} • Terenkripsi',
                    style: TextStyle(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          WtStatusBadge(label: '🔒 Aman', color: AppColors.success),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.danger))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada aset terdaftar.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
