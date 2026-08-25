import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

/// Tab Protokol Darurat — alur pencairan aset jika pewaris meninggal.
class PewarisProtokolView extends StatelessWidget {
  const PewarisProtokolView({super.key});

  static const _steps = [
    _ProtocolStep(
      title: 'Fase 1: Bukti Kehidupan Terhenti',
      desc: 'Jika Anda gagal melakukan Konfirmasi Keaktifan selama 90 hari.',
      isDone: true,
    ),
    _ProtocolStep(
      title: 'Fase 2: Notifikasi Kontak Darurat',
      desc: 'Sistem akan secara otomatis menghubungi kontak darurat terdaftar untuk menanyakan status Anda.',
      isCurrent: true,
    ),
    _ProtocolStep(
      title: 'Fase 3: Verifikasi Kematian Legal',
      desc: 'Ahli Waris mengunggah Akta Kematian resmi yang kemudian divalidasi secara legal oleh Notaris mitra WarisTech.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtSectionTitle('Pengaturan'),
          const SizedBox(height: 4),
          const Text('Protokol Darurat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          _ProtocolTimeline(steps: _steps),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Ubah Durasi Tenggang Waktu (90 Hari)', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              backgroundColor: isDark ? AppColors.navy.withOpacity(0.2) : AppColors.warm,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _ProtocolStep {
  final String title;
  final String desc;
  final bool isDone;
  final bool isCurrent;

  const _ProtocolStep({
    required this.title,
    required this.desc,
    this.isDone = false,
    this.isCurrent = false,
  });
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ProtocolTimeline extends StatelessWidget {
  final List<_ProtocolStep> steps;
  const _ProtocolTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALUR PENCAIRAN ASET (TRIGGER)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.4), letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Stack(
            children: [
              // Garis vertikal penghubung
              Positioned(
                left: 11,
                top: 12,
                bottom: 12,
                child: Container(width: 2, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.08)),
              ),
              Column(
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 24),
                    _StepItem(step: steps[i]),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final _ProtocolStep step;
  const _StepItem({required this.step});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dotColor = step.isDone
        ? AppColors.primary
        : step.isCurrent
            ? (isDark ? AppColors.darkSurface : AppColors.surface)
            : (isDark ? Colors.white : AppColors.navy).withOpacity(0.2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: step.isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: step.isDone
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : step.isCurrent
                  ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
                  : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(step.desc,
                  style: TextStyle(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
