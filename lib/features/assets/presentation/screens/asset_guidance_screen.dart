import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_guidance_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';

/// Panduan dokumen & langkah resmi untuk aset berkustodi GUIDANCE.
/// Bisa dibuka dengan data yang sudah ada (dari alur create) atau dengan
/// mengambil ulang dari server via [assetId] (GET /assets/:id/guidance).
class AssetGuidanceScreen extends ConsumerWidget {
  final String assetName;
  final AssetGuidanceEntity? preloaded;
  final String? assetId;

  const AssetGuidanceScreen({
    super.key,
    required this.assetName,
    this.preloaded,
    this.assetId,
  }) : assert(
         preloaded != null || assetId != null,
         'Wajib beri preloaded ATAU assetId',
       );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Panduan — $assetName')),
      body: preloaded != null
          ? _GuidanceBody(guidance: preloaded!)
          : _RemoteGuidanceBody(assetId: assetId!),
    );
  }
}

class _RemoteGuidanceBody extends ConsumerWidget {
  final String assetId;
  const _RemoteGuidanceBody({required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidanceAsync = ref.watch(_guidanceProvider(assetId));
    return guidanceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            e.toString(),
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ),
      data: (g) => _GuidanceBody(guidance: g),
    );
  }
}

final _guidanceProvider = FutureProvider.autoDispose
    .family<AssetGuidanceEntity, String>((ref, assetId) {
      return ref.watch(assetRepositoryProvider).getGuidance(assetId);
    });

class _GuidanceBody extends StatelessWidget {
  final AssetGuidanceEntity guidance;
  const _GuidanceBody({required this.guidance});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    guidance.summary,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Dokumen yang Perlu Disiapkan'),
          const SizedBox(height: 8),
          ..._bulletList(
            guidance.requiredDocuments,
            Icons.description_outlined,
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Langkah Teknis'),
          const SizedBox(height: 8),
          ..._numberedList(guidance.steps),
          const SizedBox(height: 24),
          const _SectionTitle('Dasar Hukum'),
          const SizedBox(height: 8),
          ..._bulletList(guidance.legalBasis, Icons.gavel_outlined),
        ],
      ),
    );
  }

  List<Widget> _bulletList(List<String> items, IconData icon) {
    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item, style: const TextStyle(height: 1.4)),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<Widget> _numberedList(List<String> items) {
    return List.generate(items.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(items[i], style: const TextStyle(height: 1.4)),
            ),
          ],
        ),
      );
    });
  }
}

/// Judul seksi pada panduan (Dokumen, Langkah Teknis, Dasar Hukum).
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}
