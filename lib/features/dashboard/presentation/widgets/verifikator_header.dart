import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

class VerifikatorHeader extends StatelessWidget {
  final String userName;
  const VerifikatorHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELAMAT DATANG',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.navy.withValues(alpha: 0.7),
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Notaris / Verifikator Legal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.navy.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
