import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

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

/// Bottom navigation mengambang — mengikuti `.float-nav` prototipe
/// (`index.html`): pil hitam melayang di tengah layar dengan lingkaran putih
/// 52px yang menonjol ke atas.
///
/// Bedanya dengan prototipe: lingkaran itu bukan milik satu tab tertentu,
/// melainkan PENANDA TAB AKTIF yang bergeser mulus ke tab mana pun yang
/// sedang dibuka.
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
  static const double _indicatorSize = 52;
  static const double _hPadding = 8;

  /// Seberapa jauh penanda menonjol di atas tepi pil.
  static const double _raise = 22;

  /// Lebar pil: 220px untuk 3 item (persis prototipe), melebar seperlunya
  /// untuk jumlah item lain agar tiap slot tetap nyaman disentuh.
  ///
  /// TIDAK PERLU lagi dilebarkan sebagai workaround supaya hump "muat" di
  /// slot terluar — itu cara lama yang rapuh (bergantung pada tuning
  /// konstanta padding/lebar yang gampang salah lagi tiap kali diubah,
  /// sudah 2× menyebabkan bug kurva geometri; lihat dokumentasi
  /// `_NavBarPainter`). Bentuk pil+tonjolan sekarang dibangun dari union
  /// dua shape sederhana (bukan bezier manual), yang valid untuk indikator
  /// di posisi MANA PUN termasuk persis di ujung.
  double get _pillWidth {
    switch (items.length) {
      case 3:
        return 220;
      case 4:
        return 288;
      default:
        return (items.length * 68 + _hPadding * 2).clamp(220, 340).toDouble();
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
        // Tinggi eksplisit (bukan Center/Align yang memuai): Scaffold
        // mengukur slot bottomNavigationBar dengan constraint tinggi LONGGAR,
        // jadi pembungkus yang memuai membuat pil melayang di tengah layar
        // alih-alih menempel di bawah.
        child: SizedBox(
          height: _pillHeight + _raise,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: _pillWidth,
                height: _pillHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Custom Latar Belakang (Pill + Hump) yang menyatu (Unified)
                    // Menggunakan Tween untuk menganimasikan perpindahan hump
                    // dengan fluid animation, shadow yang sempurna, dan glow.
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: indicatorLeft),
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        builder: (context, left, child) {
                          return CustomPaint(
                            painter: _NavBarPainter(
                              indicatorX: left + (_indicatorSize / 2),
                              indicatorSize: _indicatorSize,
                              raise: _raise,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),

                    // Ikon-ikon. Ikon tab aktif ikut naik ke dalam lingkaran.
                    Positioned.fill(
                      child: Padding(
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
                                raise: _raise,
                                onTap: () => onTap(i),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final double indicatorX;
  final double indicatorSize;
  final double raise;
  final bool isDark;

  _NavBarPainter({
    required this.indicatorX,
    required this.indicatorSize,
    required this.raise,
    required this.isDark,
  });

  /// Seberapa besar lingkaran tonjolan relatif ke lingkaran ikon (
  /// [indicatorSize]) — sedikit lebih besar supaya ada "halo" tipis di
  /// sekeliling ikon, bukan pas-pasan menempel tepi lingkaran tonjolan.
  static const double _bumpPadding = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.height / 2;

    // Bentuk pil+tonjolan dibangun dari UNION dua shape sederhana (rounded
    // rect + lingkaran) via `Path.combine`, BUKAN bezier custom yang
    // dihitung manual dari koordinat shoulder/control-point. Pendekatan
    // manual itu sudah 2× menghasilkan bug geometri nyata (notch di sudut
    // pil, lalu kurva "loop"/lepas jadi blob terpisah) setiap kali konstanta
    // layout (padding/lebar pil) berubah — karena titik kontrolnya harus
    // di-tune ulang secara manual supaya tetap valid, dan gampang lupa
    // di-cek ulang. Union path SELALU menghasilkan siluet valid untuk
    // POSISI INDIKATOR MANA PUN (termasuk persis di sudut pil) tanpa
    // perhitungan khusus kasus-tepi sama sekali — Skia yang menjamin
    // geometinya benar, bukan trigonometri kita.
    final Path pillPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final double bumpRadius = indicatorSize / 2 + _bumpPadding;
    // Puncak lingkaran (center.y - bumpRadius) disamakan dengan -raise, jadi
    // tinggi tonjolan di atas tepi pil TETAP SAMA seperti versi bezier lama.
    final double bumpCenterY = bumpRadius - raise;
    final Path bumpPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(indicatorX, bumpCenterY),
          radius: bumpRadius,
        ),
      );

    final Path shape = Path.combine(PathOperation.union, pillPath, bumpPath);

    // 1. Shadow: Lembut dan elegan
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.save();
    canvas.translate(0, 10);
    canvas.drawPath(shape, shadowPaint);
    canvas.restore();

    // 2. Base pil — hitam pekat di light mode (kontras tinggi terhadap latar
    // putih), tapi di dark mode scaffold JUGA hitam sehingga pil hitam pekat
    // nyaris tak terlihat (dibedakan cuma dari shadow & garis tepi 6%-alpha
    // yang sangat halus) — dipakai warna abu gelap yang sedikit lebih terang.
    final Paint bgPaint = Paint()
      ..color = isDark ? AppColors.darkSurface : Colors.black;
    canvas.drawPath(shape, bgPaint);

    // 3. Stroke tipis (Glass edge) di sekeliling bentuk
    // Dibuat sangat tipis dan transparan agar tidak mengganggu, hanya pemanis.
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(shape, borderPaint);
  }

  @override
  bool shouldRepaint(_NavBarPainter oldDelegate) {
    return oldDelegate.indicatorX != indicatorX ||
        oldDelegate.indicatorSize != indicatorSize ||
        oldDelegate.raise != raise ||
        oldDelegate.isDark != isDark;
  }
}

/// Satu slot pada pil nav. Saat aktif, ikonnya naik ke dalam lingkaran
/// penanda dan berubah jadi putih.
class _NavItem extends StatefulWidget {
  final WtBottomNavItem item;
  final bool isActive;
  final bool hasBadge;
  final double raise;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.hasBadge,
    required this.raise,
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
    // Dipakai warna cincin badge (lihat bawah) supaya menyatu dengan warna
    // pil di tema aktif — bukan hitam pekat tetap, yang akan tampak sebagai
    // cincin gelap yang tidak nyambung di atas pil abu terang dark-mode.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Menghitung posisi Y yang presisi untuk ikon agar berada tepat di tengah
    // puncak kurva (hump). Memberikan ruang (padding) dari puncak sebesar 8px.
    const double parentHeight = WtBottomNav._pillHeight;
    const double childHeight = 24.0;

    // Top icon = puncak (-raise) + 8px padding
    // Center icon = Top icon + childHeight / 2 = -raise + 8 + 12 = -raise + 20.
    final double targetCenterY = -widget.raise + 20.0;
    final double activeAlignmentY =
        (targetCenterY - parentHeight / 2) / ((parentHeight - childHeight) / 2);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      // Opaque: seluruh tinggi slot bisa disentuh, bukan hanya ikonnya.
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          // Ikon tab aktif naik mengikuti lingkaran penanda secara presisi.
          alignment: isActive
              ? Alignment(0, activeAlignmentY)
              : Alignment.center,
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
                  size: isActive ? 24 : 22,
                  color: isActive ? Colors.white : AppColors.gray500,
                ),
              ),
              if (widget.hasBadge)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.pulseGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? Colors.white
                            : (isDark ? AppColors.darkSurface : Colors.black),
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
