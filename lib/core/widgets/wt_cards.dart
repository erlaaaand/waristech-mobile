import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_interactions.dart';

/// Toggle bergaya kartu tinted (ikon + judul + deskripsi + switch), meniru
/// pola "Kontak Darurat"/"Eksekutor Utama" pada prototipe — pengganti
/// [CheckboxListTile] polos untuk pilihan penting yang perlu penekanan visual.
class WtToggleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const WtToggleCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.navy.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged, activeThumbColor: color),
          ],
        ),
      ),
    );
  }
}

/// Kotak dengan garis tepi putus-putus — dipakai untuk placeholder/CTA
/// "tambah data" (mis. kartu tambah aset, area unggah dokumen). Flutter
/// tidak punya `border-style: dashed`, jadi digambar manual.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final EdgeInsetsGeometry padding;

  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 16,
    this.strokeWidth = 1.5,
    this.dashLength = 5,
    this.gapLength = 4,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.gapLength != gapLength;
}

/// Card statistik dengan angka besar, label, dan ikon.
class WtStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const WtStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card info generik dengan ikon, judul, dan deskripsi.
class WtInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  // Prototipe: kartu peringatan (mis. "Akses Terkunci") pakai latar & border
  // tinted warna ikon, bukan kartu putih polos — lihat AhliWaris.js.
  final bool tinted;

  const WtInfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BouncingWrapper(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: tinted
              ? iconColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: tinted
              ? Border.all(color: iconColor.withValues(alpha: 0.2))
              : null,
          boxShadow: tinted
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: tinted ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: tinted ? 16 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: tinted
                          ? (isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.navy.withValues(alpha: 0.7))
                          : (isDark ? Colors.white : AppColors.navy).withValues(
                              alpha: 0.6,
                            ),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Kartu "surface" polos: latar putih/gelap standar + shadow lembut, tanpa
/// baris ikon (beda dari [WtInfoCard], yang selalu punya ikon+judul+deskripsi).
/// Pengganti pola `Container(decoration: BoxDecoration(color: surface,
/// borderRadius: 20, boxShadow: ...))` yang sebelumnya ditulis ulang manual
/// di banyak kartu daftar (riwayat, antrean, undangan, dsb.).
class WtSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const WtSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isDark ? Border.all(color: AppColors.primaryDark.withValues(alpha: 0.15)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return BouncingWrapper(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: card,
    );
  }
}
