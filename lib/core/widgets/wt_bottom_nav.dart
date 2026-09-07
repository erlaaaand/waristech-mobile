import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

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

/// Bottom navigation mengambang bergaya modern (Glassmorphism).
/// Pill melayang dengan efek frosted glass dan indikator aktif
/// yang bergeser mulus di belakang ikon, memberikan kesan premium
/// dan sangat nyaman dilihat.
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

  static const double _pillHeight = 64;
  static const double _hPadding = 8;
  static const double _indicatorSize = 48;

  double get _pillWidth {
    switch (items.length) {
      case 3:
        return 220;
      case 4:
        return 280;
      // 5 item (tab Profil ditambahkan ke Ahli Waris) butuh nilai lebih
      // rapat daripada formula default (336px) supaya tetap muat di layar
      // sempit (~360dp) dengan margin 20px kiri-kanan.
      case 5:
        return 300;
      default:
        return (items.length * 64 + _hPadding * 2).clamp(220, 340).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slotWidth = (_pillWidth - _hPadding * 2) / items.length;
    final indicatorLeft =
        _hPadding + slotWidth * currentIndex + (slotWidth - _indicatorSize) / 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _pillHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Glassmorphism Pill Background
              ClipRRect(
                borderRadius: BorderRadius.circular(_pillHeight / 2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: _pillWidth,
                    height: _pillHeight,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(_pillHeight / 2),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sliding Active Indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          left: indicatorLeft,
                          top: (_pillHeight - _indicatorSize) / 2,
                          child: Container(
                            width: _indicatorSize,
                            height: _indicatorSize,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Icons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _hPadding,
                          ),
                          child: Row(
                            children: List.generate(
                              items.length,
                              (i) => Expanded(
                                child: _NavItem(
                                  item: items[i],
                                  isActive: i == currentIndex,
                                  hasBadge: showBadge && badgeIndex == i,
                                  onTap: () => onTap(i),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _NavItem extends StatefulWidget {
  final WtBottomNavItem item;
  final bool isActive;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.hasBadge,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          // Subtle animation already handled by Scale and Icon size changes
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  isActive ? widget.item.iconFilled : widget.item.icon,
                  key: ValueKey(isActive),
                  size: isActive ? 26 : 24,
                  color: isActive
                      ? (isDark ? Colors.white : AppColors.primary)
                      : (isDark ? Colors.white54 : AppColors.gray400),
                ),
              ),
              if (widget.hasBadge)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.pulseGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkSurface : Colors.white,
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
