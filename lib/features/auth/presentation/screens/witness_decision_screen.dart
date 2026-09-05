import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

/// Layar keputusan Saksi (APPROVE/DISPUTE) — POST /inheritance/witness/decision.
/// Ditampilkan setelah sesi Guest terbentuk via [WitnessMagicLinkScreen].
/// `witnessId` yang dikirim ke backend adalah ID user Guest saat ini
/// (backend menyamakan `sub` JWT Guest dengan ID record Witness itu sendiri).
class WitnessDecisionScreen extends ConsumerStatefulWidget {
  const WitnessDecisionScreen({super.key});

  @override
  ConsumerState<WitnessDecisionScreen> createState() =>
      _WitnessDecisionScreenState();
}

class _WitnessDecisionScreenState extends ConsumerState<WitnessDecisionScreen> {
  bool _submitted = false;

  Future<void> _decide(String decision) async {
    final witnessId = ref.read(authProvider).valueOrNull?.id;
    if (witnessId == null || witnessId.isEmpty) return;

    final confirmed = await WtConfirmDialog.show(
      context,
      title: decision == 'APPROVE'
          ? 'Setujui Pembagian Warisan?'
          : 'Sanggah Pembagian Warisan?',
      message: decision == 'APPROVE'
          ? 'Anda menyatakan bahwa proses ini sah dan dapat dilanjutkan.'
          : 'Aset akan DIBEKUKAN untuk ditinjau ulang. Gunakan hanya jika Anda menduga ada kejanggalan.',
      confirmLabel: 'Ya, Lanjutkan',
      confirmColor: decision == 'APPROVE'
          ? AppColors.success
          : AppColors.danger,
    );
    if (!confirmed) return;

    await ref
        .read(witnessDecisionProvider.notifier)
        .submit(witnessId: witnessId, decision: decision);
    if (!mounted) return;
    final state = ref.read(witnessDecisionProvider);
    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isLoading = ref.watch(witnessDecisionProvider).isLoading;
    final isDone = _submitted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keputusan Saksi'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isDone
              ? _SuccessView(name: user?.name ?? 'Saksi')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${user?.name ?? 'Saksi'}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Anda diminta menjadi Saksi/Kontak Darurat dalam proses '
                        'verifikasi kematian di WarisTech. Keputusan Anda bersifat '
                        'final dan tidak dapat diubah setelah dikirim.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _decide('APPROVE'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('SETUJUI (APPROVE)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : () => _decide('DISPUTE'),
                        icon: const Icon(Icons.report_problem_outlined),
                        label: const Text('SANGGAH (DISPUTE)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String name;
  const _SuccessView({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          const SizedBox(height: 20),
          const Text(
            'Keputusan Terkirim',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Terima kasih, $name. Anda dapat menutup halaman ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}
