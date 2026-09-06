import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/ahli_waris_lacak_components.dart';

class AhliWarisLacakView extends ConsumerWidget {
  const AhliWarisLacakView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync = ref.watch(myFamilyMembershipProvider);
    final allocatedAssetsAsync = ref.watch(allocatedAssetsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Belum ada endpoint yang mengekspos status verifikasi akta kematian /
    // saksi ke Ahli Waris (hanya Notaris) — jadi tahap 2 & 3 tidak bisa
    // diturunkan langsung dari sumber aslinya. Tahap 4 (pelepasan kunci)
    // BISA: kalau ada aset teralokasi yang sudah distributed/closed, itu
    // bukti nyata seluruh rantai verifikasi (termasuk tahap 2 & 3) sudah
    // selesai — dipakai untuk menaikkan status tahap-tahap sebelumnya juga.
    final keyReleaseDone = allocatedAssetsAsync.maybeWhen(
      data: (assets) => assets.any(
        (a) =>
            a.status == AssetStatus.distributed ||
            a.status == AssetStatus.closed,
      ),
      orElse: () => false,
    );

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
                          i < _steps(pewarisName, keyReleaseDone).length;
                          i++
                        ) ...[
                          if (i > 0) const SizedBox(height: 24),
                          LegalTimelineItem(
                            step: _steps(pewarisName, keyReleaseDone)[i],
                          ),
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

  List<TimelineStep> _steps(String? pewarisName, bool keyReleaseDone) => [
    TimelineStep(
      title: 'Pewaris Terdaftar',
      desc: pewarisName != null
          ? 'Sistem memonitor status Proof-of-Life $pewarisName.'
          : 'Sistem memonitor status Proof-of-Life Pewaris Anda.',
      isDone: true,
    ),
    TimelineStep(
      title: 'Akta Kematian',
      desc: 'Ajukan dokumen akta kematian resmi Dukcapil dari tab Lapor Kematian.',
      isDone: keyReleaseDone,
      isCurrent: !keyReleaseDone,
    ),
    TimelineStep(
      title: 'Validasi Notaris & Saksi',
      desc:
          'Notaris memverifikasi dokumen; minimal 3 Saksi memberi persetujuan.',
      isDone: keyReleaseDone,
    ),
    TimelineStep(
      title: 'Pelepasan Kunci Brankas',
      desc: "Pecahan kunci Shamir's Secret Sharing dibagikan ke Eksekutor.",
      isDone: keyReleaseDone,
    ),
  ];
}
