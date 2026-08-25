import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

// =============================================================================
// LOGO WIDGETS
// =============================================================================

/// Logo WarisTech dari SVG asset.
class WtLogo extends StatelessWidget {
  final double size;
  const WtLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/logo.svg', width: size, height: size);
  }
}

/// Logo WarisTech dengan teks judul di sebelahnya.
class WtLogoWithText extends StatelessWidget {
  final String title;
  const WtLogoWithText({super.key, this.title = 'WarisTech'});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WtLogo(size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ],
    );
  }
}

// =============================================================================
// BOTTOM NAVIGATION
// =============================================================================

/// Data model untuk item bottom navigation.
class WtBottomNavItem {
  final String id;
  final IconData icon;
  final IconData iconFilled;

  const WtBottomNavItem({
    required this.id,
    required this.icon,
    required this.iconFilled,
  });
}

/// Bottom navigation bar berdesain kapsul sesuai prototype.
class WtBottomNav extends StatelessWidget {
  final List<WtBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showBadge;
  final int? badgeIndex;

  const WtBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showBadge = false,
    this.badgeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF09090B) : Colors.white).withOpacity(0.92),
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => _NavItem(
                item: items[i],
                isActive: i == currentIndex,
                hasBadge: showBadge && badgeIndex == i,
                isDark: isDark,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final WtBottomNavItem item;
  final bool isActive;
  final bool hasBadge;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.hasBadge,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  isActive ? item.iconFilled : item.icon,
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                  size: 24,
                ),
              ),
              if (hasBadge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF09090B) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REUSABLE CARD WIDGETS (DRY untuk semua dashboard)
// =============================================================================

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
        color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.5),
        letterSpacing: 1.5,
      ),
    );
  }
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.2)),
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
                color: color.withOpacity(0.8),
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

  const WtInfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: (isDark ? Colors.white : AppColors.navy)
                          .withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Badge status berwarna (Aktif, Menunggu, dll.).
class WtStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const WtStatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
