import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

class ProtocolStep {
  final String title;
  final String desc;
  final bool isDone;
  final bool isCurrent;

  const ProtocolStep({
    required this.title,
    required this.desc,
    this.isDone = false,
    this.isCurrent = false,
  });
}

class ProtocolTimeline extends StatelessWidget {
  final List<ProtocolStep> steps;
  const ProtocolTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.gray50,
        border: Border.all(
          color: isDark ? AppColors.gray800 : AppColors.gray200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ALUR PENCAIRAN ASET (TRIGGER)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.gray400,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Positioned(
                left: 9,
                top: 10,
                bottom: 10,
                child: Container(
                  width: 2,
                  color: (isDark ? Colors.white : AppColors.navy).withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              Column(
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 24),
                    StepItem(step: steps[i]),
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

class StepItem extends StatelessWidget {
  final ProtocolStep step;
  const StepItem({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dotColor = step.isDone
        ? AppColors.primary
        : step.isCurrent
        ? (isDark ? AppColors.darkSurface : AppColors.surface)
        : (isDark ? Colors.white : AppColors.navy).withValues(alpha: 0.2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: step.isCurrent
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: step.isDone
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : step.isCurrent
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.desc,
                style: TextStyle(
                  color: (isDark ? Colors.white : AppColors.navy).withValues(
                    alpha: 0.6,
                  ),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
