import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

class TimelineStep {
  final String title;
  final String desc;
  final bool isDone;
  final bool isCurrent;

  const TimelineStep({
    required this.title,
    required this.desc,
    this.isDone = false,
    this.isCurrent = false,
  });
}

class LegalTimelineItem extends StatelessWidget {
  final TimelineStep step;
  const LegalTimelineItem({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInactive = !step.isDone && !step.isCurrent;

    final dotBg = step.isDone
        ? (isDark ? Colors.white : AppColors.navy)
        : step.isCurrent
        ? (isDark ? AppColors.darkSurface : Colors.white)
        : (isDark ? Colors.white : AppColors.navy).withValues(alpha: 0.2);

    return Opacity(
      opacity: isInactive ? 0.3 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: dotBg,
              shape: BoxShape.circle,
              border: step.isCurrent
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            alignment: Alignment.center,
            child: step.isDone
                ? Icon(
                    Icons.check,
                    color: isDark ? AppColors.navy : Colors.white,
                    size: 12,
                  )
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: step.isCurrent ? AppColors.primary : null,
                  ),
                ),
                const SizedBox(height: 2),
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
      ),
    );
  }
}
