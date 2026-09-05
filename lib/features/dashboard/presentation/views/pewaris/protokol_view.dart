import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/inheritance/presentation/screens/witness_management_screen.dart';
import 'package:wt_mobile/features/proof_of_life/domain/entities/proof_of_life_status_entity.dart';
import 'package:wt_mobile/features/proof_of_life/presentation/providers/proof_of_life_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/protokol_components.dart';

class PewarisProtokolView extends ConsumerWidget {
  const PewarisProtokolView({super.key});

  List<ProtocolStep> _stepsFor(ProofOfLifeStage? stage) {
    final isPastCheckIn = stage != null && stage != ProofOfLifeStage.active;
    final isFormalVerification = stage == ProofOfLifeStage.formalVerification;

    return [
      ProtocolStep(
        title: 'Fase 1: Bukti Kehidupan Terhenti',
        desc: 'Terpicu jika Anda gagal melakukan Konfirmasi Keaktifan selama 30 hari.',
        isDone: isPastCheckIn,
        isCurrent: stage == ProofOfLifeStage.warning,
      ),
      ProtocolStep(
        title: 'Fase 2: Notifikasi Kontak Darurat',
        desc: 'Sistem menghubungi Saksi/Kontak Darurat terdaftar untuk menanyakan status Anda (hari ke-15 s.d. ke-30 pasca-checkpoint).',
        isDone: isFormalVerification,
        isCurrent: stage == ProofOfLifeStage.emergencyContact,
      ),
      ProtocolStep(
        title: 'Fase 3: Verifikasi Kematian Legal',
        desc: 'Ahli Waris mengunggah Akta Kematian resmi yang kemudian divalidasi Notaris.',
        isCurrent: isFormalVerification,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusAsync = ref.watch(proofOfLifeStatusProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Protokol Darurat',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.44,
            ),
          ),
          const SizedBox(height: 16),
          statusAsync.when(
            loading: () => ProtocolTimeline(steps: _stepsFor(null)),
            error: (_, _) => ProtocolTimeline(steps: _stepsFor(null)),
            data: (status) => ProtocolTimeline(steps: _stepsFor(status.stage)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WitnessManagementScreen(),
              ),
            ),
            icon: const Icon(Icons.groups_outlined, size: 20),
            label: const Text(
              'Kelola Saksi / Kontak Darurat',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black,
              side: BorderSide(
                color: isDark ? AppColors.gray800 : AppColors.gray200,
              ),
              backgroundColor: isDark ? AppColors.darkCard : AppColors.gray50,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
