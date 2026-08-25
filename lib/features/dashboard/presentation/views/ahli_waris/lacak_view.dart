import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

/// Tab Lacak Verifikasi — timeline status proses legal.
class AhliWarisLacakView extends StatelessWidget {
  const AhliWarisLacakView({super.key});

  static const _steps = [
    _TimelineStep(title: 'Pewaris Terdaftar', desc: 'Sistem memonitor aktivitas Bapak Budi Santoso.', isDone: true),
    _TimelineStep(title: 'Menunggu Akta Kematian', desc: 'Anda belum mengunggah dokumen bukti kematian.', isCurrent: true),
    _TimelineStep(title: 'Validasi Notaris', desc: 'Notaris akan memverifikasi keabsahan dokumen.'),
    _TimelineStep(title: 'Pelepasan Kunci Brankas', desc: "Pecahan kunci Shamir's Secret Sharing dibagikan."),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtSectionTitle('Status'),
          const SizedBox(height: 4),
          const Text('Verifikasi Legal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 9, top: 12, bottom: 12,
                  child: Container(width: 2, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.08)),
                ),
                Column(
                  children: [
                    for (int i = 0; i < _steps.length; i++) ...[
                      if (i > 0) const SizedBox(height: 24),
                      _TimelineItem(step: _steps[i]),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TimelineStep {
  final String title;
  final String desc;
  final bool isDone;
  final bool isCurrent;

  const _TimelineStep({required this.title, required this.desc, this.isDone = false, this.isCurrent = false});
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;
  const _TimelineItem({required this.step});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInactive = !step.isDone && !step.isCurrent;

    final dotBg = step.isDone
        ? (isDark ? Colors.white : AppColors.navy)
        : step.isCurrent
            ? (isDark ? AppColors.darkSurface : Colors.white)
            : (isDark ? Colors.white : AppColors.navy).withOpacity(0.2);

    return Opacity(
      opacity: isInactive ? 0.3 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: dotBg,
              shape: BoxShape.circle,
              border: step.isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: step.isDone
                ? Icon(Icons.check, color: isDark ? AppColors.navy : Colors.white, size: 12)
                : step.isCurrent
                    ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: step.isCurrent ? AppColors.primary : null)),
                const SizedBox(height: 2),
                Text(step.desc,
                    style: TextStyle(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
