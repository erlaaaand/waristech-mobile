import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/calculation/presentation/providers/calculation_provider.dart';
import 'package:wt_mobile/features/calculation/presentation/screens/simulation_result_screen.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/hukum_waris_components.dart';

const _methodValues = ['CIVIL', 'CUSTOMARY', 'FARAIDH'];
const _schemeLabels = ['Perdata', 'Adat', 'Faraidh'];

class PewarisHukumWarisView extends ConsumerWidget {
  const PewarisHukumWarisView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyMembersProvider);
    final preferenceAsync = ref.watch(calculationPreferenceProvider);
    final isSaving = ref.watch(setPreferenceProvider).isLoading;

    Future<void> onSchemeChanged(int index) async {
      await ref
          .read(setPreferenceProvider.notifier)
          .setPreference(_methodValues[index]);
      final result = ref.read(setPreferenceProvider);
      if (result.hasError && context.mounted) {
        WtSnackbar.error(context, result.error.toString());
      }
    }

    final selectedIndex = preferenceAsync.maybeWhen(
      data: (method) => _methodValues.indexOf(method ?? ''),
      orElse: () => -1,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skema Waris',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.44,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Skema yang dipilih menjadi acuan validasi saat mengalokasikan aset ke ahli waris.',
            style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
          ),
          const SizedBox(height: 20),
          if (isSaving)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(),
            ),
          SchemeSelector(
            schemes: _schemeLabels,
            selectedIndex: selectedIndex,
            onChanged: isSaving ? (_) {} : onSchemeChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: selectedIndex < 0
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SimulationResultScreen(
                          method: _methodValues[selectedIndex],
                          methodLabel: _schemeLabels[selectedIndex],
                        ),
                      ),
                    ),
              icon: const Icon(Icons.calculate_outlined, size: 18),
              label: const Text(
                'Lihat Simulasi Pembagian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          familyAsync.when(
            loading: () => const CardSkeleton(),
            error: (_, _) => SummaryCard(
              schemeName: selectedIndex >= 0
                  ? _schemeLabels[selectedIndex]
                  : '—',
              memberCount: 0,
            ),
            data: (members) => SummaryCard(
              schemeName: selectedIndex >= 0
                  ? _schemeLabels[selectedIndex]
                  : '—',
              memberCount: members.length,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const WtSectionTitle('Ahli Waris'),
              TextButton.icon(
                onPressed: () => context.pushNamed('invitations'),
                icon: const Icon(Icons.add_circle, size: 16),
                label: const Text(
                  'Undang',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          familyAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => WtErrorBanner(message: e.toString()),
            data: (members) => members.isEmpty
                ? const WtEmptyState(
                    message: 'Belum ada ahli waris terdaftar.',
                    subtitle:
                        'Bagikan kode undangan untuk menambahkan ahli waris.',
                    icon: Icons.people_outline,
                  )
                : Column(
                    children: members
                        .map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HeirCard(member: m),
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
