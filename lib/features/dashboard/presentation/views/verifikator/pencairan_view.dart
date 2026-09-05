import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/verifikator_pencairan_components.dart';

class VerifikatorPencairanView extends ConsumerWidget {
  const VerifikatorPencairanView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proofsAsync = ref.watch(pendingLiquidationReviewsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WtScreenHeader(
            label: 'Notaris',
            title: 'Tinjau Pencairan',
            trailing: TextButton(
              onPressed: () =>
                  ref.invalidate(pendingLiquidationReviewsProvider),
              child: const Text('Refresh'),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Buka dokumen e-Statement, lalu putuskan APPROVE atau REJECT secara manual.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.gray500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          proofsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => WtErrorBanner(message: e.toString()),
            data: (proofs) => proofs.isEmpty
                ? const WtEmptyState(
                    message:
                        'Tidak ada bukti pencairan yang menunggu tinjauan.',
                    icon: Icons.task_alt,
                    iconColor: AppColors.success,
                  )
                : Column(
                    children: proofs
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ProofReviewCard(proof: p),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
