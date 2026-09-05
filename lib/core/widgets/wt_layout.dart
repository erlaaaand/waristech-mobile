import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

/// Panel kaca buram (frosted glass) — aksen glassmorphism dipakai SELEKTIF
/// di atas latar berwarna/gradient (navy/amber) yang sudah jadi identitas
/// inti WarisTech, mis. kartu hero dashboard & modal bottom sheet. BUKAN
/// pengganti `WtInfoCard`/`WtStatCard` di seluruh app — dipasang cuma di
/// elemen yang sengaja ingin terasa "mengambang".
class WtGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color tintColor;
  final double tintOpacity;

  const WtGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 16,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tintColor.withValues(alpha: tintOpacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: tintColor.withValues(alpha: tintOpacity + 0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Label section title dengan gaya uppercase+letterSpacing seragam.
class WtSectionTitle extends StatelessWidget {
  final String text;
  const WtSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        // Prototipe: text-navy/70 dark:text-white/40 (BUKAN 0.5 untuk keduanya).
        color: isDark
            ? Colors.white.withValues(alpha: 0.4)
            : AppColors.navy.withValues(alpha: 0.7),
        letterSpacing: 1.3,
      ),
    );
  }
}

/// Header baku setiap tab/layar: label kecil (WtSectionTitle) + judul besar.
/// Mengganti pola berulang `WtSectionTitle + SizedBox(4) + Text(28,w800,-0.7)`
/// yang sebelumnya ditulis manual di setiap view.
class WtScreenHeader extends StatelessWidget {
  final String label;
  final String title;
  final Widget? trailing;

  const WtScreenHeader({
    super.key,
    required this.label,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WtSectionTitle(label),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            // Tailwind tracking-tight = -0.025em → 28px * -0.025 = -0.7px.
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
    if (trailing == null) return header;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: header),
        trailing!,
      ],
    );
  }
}
