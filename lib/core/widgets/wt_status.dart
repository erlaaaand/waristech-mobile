import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

/// Badge status berwarna (Aktif, Menunggu, dll.).
class WtStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  // Prototipe: sebagian badge pakai titik kecil (mis. riwayat eksekusi),
  // bukan ikon — diabaikan jika [icon] diisi.
  final bool dot;

  const WtStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ] else if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol aksi utama lebar penuh.
class WtPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const WtPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          foregroundColor: isDark ? AppColors.primaryDeep : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.primaryDeep : Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
