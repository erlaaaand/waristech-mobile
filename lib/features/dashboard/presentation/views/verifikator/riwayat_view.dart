import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/verifikator_riwayat_components.dart';

/// Tab Riwayat Keputusan untuk role Verifikator/Notaris —
/// GET /assets/notaris/history.
class VerifikatorRiwayatView extends ConsumerStatefulWidget {
  const VerifikatorRiwayatView({super.key});

  @override
  ConsumerState<VerifikatorRiwayatView> createState() =>
      _VerifikatorRiwayatViewState();
}

class _VerifikatorRiwayatViewState
    extends ConsumerState<VerifikatorRiwayatView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(verificationHistoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WtScreenHeader(
            label: 'Riwayat',
            title: 'Keputusan Legal',
            trailing: TextButton(
              onPressed: () => ref.invalidate(verificationHistoryProvider),
              child: const Text('Refresh'),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Cari nama aset atau platform...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          historyAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => WtErrorBanner(message: e.toString()),
            data: (assets) {
              final filtered = _query.isEmpty
                  ? assets
                  : assets
                        .where(
                          (a) =>
                              a.assetName.toLowerCase().contains(_query) ||
                              a.platform.toLowerCase().contains(_query),
                        )
                        .toList();
              if (filtered.isEmpty) {
                return const WtEmptyState(
                  message: 'Belum ada riwayat keputusan.',
                );
              }
              return Column(
                children: filtered
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HistoryCard(asset: a),
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
