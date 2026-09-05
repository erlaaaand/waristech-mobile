import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/ahli_waris_lacak_components.dart';

class AhliWarisLacakView extends ConsumerWidget {
  const AhliWarisLacakView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync = ref.watch(myFamilyMembershipProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtScreenHeader(label: 'Status', title: 'Verifikasi Legal'),
          const SizedBox(height: 24),
          membershipAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text(
              e.toString(),
              style: const TextStyle(color: AppColors.danger),
            ),
            data: (items) {
              final entries = items.whereType<Map<String, dynamic>>().toList();
              final pewarisName = entries.isNotEmpty
                  ? entries.first['pewarisName']?.toString()
                  : null;
              return WtSurfaceCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Stack(
                  children: [
                    Positioned(
                      left: 9,
                      top: 12,
                      bottom: 12,
                      child: Container(
                        width: 2,
                        color: (isDark ? Colors.white : AppColors.navy)
                            .withValues(alpha: 0.08),
                      ),
                    ),
                    Column(
                      children: [
                        for (
                          int i = 0;
                          i < _steps(pewarisName).length;
                          i++
                        ) ...[
                          if (i > 0) const SizedBox(height: 24),
                          LegalTimelineItem(step: _steps(pewarisName)[i]),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<TimelineStep> _steps(String? pewarisName) => [
    TimelineStep(
      title: 'Pewaris Terdaftar',
      desc: pewarisName != null
          ? 'Sistem memonitor status Proof-of-Life $pewarisName.'
          : 'Sistem memonitor status Proof-of-Life Pewaris Anda.',
      isDone: true,
    ),
    const TimelineStep(
      title: 'Akta Kematian',
      desc: 'Ajukan dokumen akta kematian resmi Dukcapil dari tab Lapor Kematian.',
      isCurrent: true,
    ),
    const TimelineStep(
      title: 'Validasi Notaris & Saksi',
      desc:
          'Notaris memverifikasi dokumen; minimal 3 Saksi memberi persetujuan.',
    ),
    const TimelineStep(
      title: 'Pelepasan Kunci Brankas',
      desc: "Pecahan kunci Shamir's Secret Sharing dibagikan ke Eksekutor.",
    ),
  ];
}
