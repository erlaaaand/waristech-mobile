import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/calculation/domain/entities/calculation_result_entity.dart';
import 'package:wt_mobile/features/calculation/presentation/providers/calculation_provider.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

const _customaryMethod = 'CUSTOMARY';

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
  final Map<String, TextEditingController> _ratioCtrls = {};

  bool get _isCustomary => widget.method == _customaryMethod;

  @override
  void initState() {
    super.initState();
    if (!_isCustomary) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(simulateProvider.notifier).simulate(widget.method);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ratioCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _totalEntered() => _ratioCtrls.values.fold<double>(
    0,
    (sum, c) => sum + (double.tryParse(c.text.trim()) ?? 0),
  );

  void _submitCustomaryRatios(List<Map<String, dynamic>> members) {
    final ratios = members.map((m) {
      final ahliWarisId = m['ahliWarisId']?.toString() ?? '';
      final ratio = double.tryParse(
            _ratioCtrls[ahliWarisId]?.text.trim() ?? '',
          ) ??
          0;
      return {'ahliWarisId': ahliWarisId, 'ratioPercentage': ratio};
    }).toList();

    ref
        .read(simulateProvider.notifier)
        .simulate(widget.method, customaryRatios: ratios);
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
              if (_isCustomary && resultAsync.valueOrNull == null)
                _CustomaryRatioForm(
                  controllersFor: (members) {
                    for (final m in members) {
                      final id = m['ahliWarisId']?.toString() ?? '';
                      _ratioCtrls.putIfAbsent(id, () => TextEditingController());
                    }
                    return _ratioCtrls;
                  },
                  totalEntered: _totalEntered,
                  isSubmitting: resultAsync.isLoading,
                  errorMessage: resultAsync.hasError
                      ? resultAsync.error.toString()
                      : null,
                  onRefresh: () => setState(() {}),
                  onSubmit: _submitCustomaryRatios,
                )
              else
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

/// Form input rasio kustom per ahli waris — wajib untuk skema Adat karena
/// backend tidak punya aturan baku (tidak seperti Faraidh/Perdata), jadi
/// Pewaris yang menentukan sendiri porsinya sebelum simulasi bisa dijalankan.
class _CustomaryRatioForm extends ConsumerWidget {
  final Map<String, TextEditingController> Function(
    List<Map<String, dynamic>> members,
  )
  controllersFor;
  final double Function() totalEntered;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final void Function(List<Map<String, dynamic>> members) onSubmit;

  const _CustomaryRatioForm({
    required this.controllersFor,
    required this.totalEntered,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onRefresh,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyMembersProvider);

    return familyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => WtErrorBanner(message: e.toString()),
      data: (raw) {
        final members = raw.whereType<Map<String, dynamic>>().toList();
        if (members.isEmpty) {
          return const WtEmptyState(
            message: 'Belum ada ahli waris terdaftar.',
            subtitle: 'Tambahkan ahli waris terlebih dahulu sebelum simulasi.',
            icon: Icons.people_outline,
          );
        }

        final ctrls = controllersFor(members);
        final total = totalEntered();
        final isExactlyFull = (total - 100).abs() < 0.01;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WtSectionTitle('Rasio Per Ahli Waris'),
            const SizedBox(height: 4),
            const Text(
              'Skema Adat tidak punya aturan baku — tentukan sendiri persentase tiap ahli waris (total harus 100%).',
              style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
            ),
            const SizedBox(height: 16),
            ...members.map((m) {
              final id = m['ahliWarisId']?.toString() ?? '';
              final label = (m['relationshipDescription']?.toString().isNotEmpty ?? false)
                  ? m['relationshipDescription'].toString()
                  : 'Ahli waris';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: ctrls[id],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.end,
                        onChanged: (_) => onRefresh(),
                        decoration: const InputDecoration(
                          suffixText: '%',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
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
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              WtErrorBanner(message: errorMessage!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isExactlyFull && !isSubmitting)
                    ? () => onSubmit(members)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Hitung Simulasi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        );
      },
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
