import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/calculation/domain/entities/calculation_result_entity.dart';
import 'package:wt_mobile/features/calculation/presentation/providers/calculation_provider.dart';

/// Simulasi pembagian waris — POST /calculation/simulate.
///
/// PENTING: ini hanya alat bantu pemahaman, BUKAN penetapan hukum final.
/// Pembagian resmi tetap melalui Surat Keterangan Waris/penetapan pengadilan
/// — disclaimer ini wajib tampil, bukan hanya tercantum di dokumen proposal.
class SimulationResultScreen extends ConsumerStatefulWidget {
  final String method;
  final String methodLabel;

  const SimulationResultScreen({
    super.key,
    required this.method,
    required this.methodLabel,
  });

  @override
  ConsumerState<SimulationResultScreen> createState() =>
      _SimulationResultScreenState();
}

class _SimulationResultScreenState
    extends ConsumerState<SimulationResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simulateProvider.notifier).simulate(widget.method);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(simulateProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Simulasi ${widget.methodLabel}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DisclaimerBanner(),
              const SizedBox(height: 20),
              resultAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => WtErrorBanner(message: e.toString()),
                data: (result) {
                  if (result == null || result.shares.isEmpty) {
                    return const WtEmptyState(
                      message: 'Belum bisa disimulasikan.',
                      subtitle:
                          'Pastikan sudah ada aset terverifikasi dan ahli waris yang dikonfirmasi.',
                      icon: Icons.calculate_outlined,
                    );
                  }
                  return _SimulationResult(result: result);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return const WtInfoCard(
      icon: Icons.info_outline,
      iconColor: AppColors.amber,
      title: 'Alat Bantu Pemahaman',
      description:
          'Simulasi ini BUKAN penetapan hukum final. Pembagian resmi waris '
          'tetap melalui Surat Keterangan Waris atau penetapan pengadilan.',
      tinted: true,
    );
  }
}

class _SimulationResult extends StatelessWidget {
  final CalculationResultEntity result;

  const _SimulationResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final total = result.totalPercentage;
    final isExactlyFull = (total - 100).abs() < 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WtSectionTitle('Rincian Pembagian'),
        const SizedBox(height: 12),
        ...result.shares.map(
          (share) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ShareRow(share: share),
          ),
        ),
        const SizedBox(height: 8),
        WtSurfaceCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              Text(
                '${total.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isExactlyFull ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareRow extends StatelessWidget {
  final ShareDetailEntity share;

  const _ShareRow({required this.share});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return WtSurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  share.relationshipDescription.isNotEmpty
                      ? share.relationshipDescription
                      : 'Ahli waris',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  share.ratio,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.navy.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${share.calculatedPercentage.toStringAsFixed(2)}%',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
