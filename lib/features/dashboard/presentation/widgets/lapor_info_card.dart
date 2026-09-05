import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

class LaporInfoCard extends StatelessWidget {
  const LaporInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return WtSurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dokumen Resmi Dukcapil',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unggah foto atau scan Akta Kematian resmi. Dokumen ini akan ditinjau langsung oleh Notaris — syarat pihak resmi/netral dalam verifikasi berjenjang, selain persetujuan minimal 3 saksi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.navy.withValues(alpha: 0.7),
                    height: 1.5,
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
