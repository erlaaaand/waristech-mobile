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

/// Header standar Beranda/tab-utama KETIGA role — dimodelkan dari header
/// Pewaris (avatar bulat tap→Profil, sapaan, ikon notifikasi). Sejak AppBar
/// dihapus dari shell Ahli Waris/Notaris (lihat `*_dashboard_screen.dart`),
/// widget ini jadi satu-satunya sumber akses avatar→Profil di ketiga role.
/// [subtitle] opsional untuk info spesifik-role (mis. badge "Eksekutor"
/// Ahli Waris, caption "Notaris / Verifikator Legal") yang sebelumnya ada
/// di `AhliWarisHeader`/`VerifikatorHeader` (kini dihapus).
///
/// TIDAK membawa padding horizontal sendiri — pemanggil punya skema padding
/// tab masing-masing (Pewaris: 24px lewat wrapper eksplisit; Ahli Waris/
/// Notaris: 20px sudah dari `SingleChildScrollView` induknya) yang berbeda
/// tipis, disengaja supaya tidak dobel-padding dengan konten lain di tab
/// yang sama.
class DashboardHomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onOpenProfile;
  final Widget? subtitle;

  const DashboardHomeHeader({
    super.key,
    required this.userName,
    required this.onOpenProfile,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onOpenProfile,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: isDark
                ? AppColors.darkSurface
                : AppColors.primaryLightest,
            child: Text(
              userName.trim().isNotEmpty
                  ? userName.trim()[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang,',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.primary.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userName,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[const SizedBox(height: 3), subtitle!],
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.gray100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.gray700,
            size: 20,
          ),
        ),
      ],
    );
  }
}
