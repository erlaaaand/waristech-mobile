import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

const _kAccentGlow = Color(0xFF38BDF8);

/// Splash Flutter-side, tampil selama sesi login diperiksa (`authProvider`
/// loading) — durasinya TIDAK tetap, bisa hanya sepersekian detik di
/// perangkat cepat atau lebih lama di jaringan lambat. Warna latar SENGAJA
/// disamakan persis dengan `flutter_native_splash.yaml` (`#000000` di kedua
/// tema) agar transisi dari splash native (dirender OS sebelum Flutter
/// boot) ke sini terasa mulus tanpa "kedipan" warna.
///
/// Animasi dipecah jadi 2 ticker supaya tetap ringan:
/// - [_entrance]: one-shot (~1.6s) — logo, wordmark per-huruf, tagline, dan
///   indikator muat masuk berurutan (staggered), lalu BERHENTI total (tidak
///   ada Ticker yang jalan lagi setelahnya).
/// - [_loop]: repeating, HANYA menggerakkan elemen dekoratif murah (titik
///   mengorbit + arc pemuat berputar + kedipan glow lembut lewat `sin`) —
///   murni `CustomPainter`/compositing opacity, tanpa gambar/Lottie, supaya
///   splash tetap terasa hidup kalau pemeriksaan sesi lebih lama tanpa
///   membebani device.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _word = 'WarisTech';

  late final AnimationController _entrance;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// Memetakan [_entrance.value] ke progres 0..1 lokal untuk satu segmen
  /// timeline (mis. 0.0–0.55 untuk logo) — dasar dari seluruh staggering
  /// tanpa perlu banyak `AnimationController`/`CurvedAnimation` terpisah.
  double _seg(double begin, double end, [Curve curve = Curves.easeOut]) {
    if (end <= begin) return _entrance.value >= begin ? 1.0 : 0.0;
    final t = ((_entrance.value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Prototipe & flutter_native_splash.yaml sama-sama #000000 di kedua
    // tema — dipertahankan lewat token semantik (bukan Colors.black
    // langsung) supaya niat "ikut tema" tetap terbaca di kode.
    final background = isDark ? AppColors.darkBackground : AppColors.navy;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: Listenable.merge([_entrance, _loop]),
                builder: (context, _) {
                  final logoT = _seg(0.0, 0.55, Curves.easeOutBack);
                  final glowT = _seg(0.05, 0.5);
                  final orbitT = _seg(0.15, 0.6);

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: orbitT * 0.7,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: _OrbitPainter(
                              angle: _loop.value * 2 * math.pi,
                            ),
                          ),
                        ),
                      ),
                      Opacity(opacity: glowT, child: _PulseGlow(loop: _loop)),
                      Transform.scale(
                        scale: 0.6 + 0.4 * logoT,
                        child: Opacity(
                          // `easeOutBack` sengaja overshoot >1.0 untuk efek
                          // pantulan pada scale — TIDAK valid dipakai
                          // langsung sebagai opacity, jadi di-clamp di sini.
                          opacity: logoT.clamp(0.0, 1.0),
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Center(child: WtLogo(size: 52)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _entrance,
              builder: (context, _) => _StaggeredWord(
                word: _word,
                value: _entrance.value,
                begin: 0.35,
                end: 0.65,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _entrance,
              builder: (context, _) {
                final taglineT = _seg(0.55, 0.85);
                return Opacity(
                  opacity: taglineT,
                  child: Transform.translate(
                    offset: Offset(0, (1 - taglineT) * 8),
                    child: Text(
                      'Warisan Digital yang Amanah',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 36),
            AnimatedBuilder(
              animation: Listenable.merge([_entrance, _loop]),
              builder: (context, _) {
                final loadingT = _seg(0.8, 1.0);
                return Opacity(
                  opacity: loadingT,
                  child: _SpinningArc(loop: _loop),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Wordmark "WarisTech" muncul huruf-per-huruf (fade + slide naik) dalam
/// jendela [begin]..[end] pada timeline entrance — efek "ketik" ringan
/// tanpa `Animation` terpisah per huruf, murni aritmatika dari [value].
class _StaggeredWord extends StatelessWidget {
  final String word;
  final double value;
  final double begin;
  final double end;

  const _StaggeredWord({
    required this.word,
    required this.value,
    required this.begin,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    final letters = word.split('');
    final n = letters.length;
    final perLetterWindow = (end - begin) * 0.6;
    final step = n > 1 ? (end - begin - perLetterWindow) / (n - 1) : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(n, (i) {
        final localBegin = begin + step * i;
        final localEnd = (localBegin + perLetterWindow).clamp(0.0, 1.0);
        final t = localEnd <= localBegin
            ? (value >= localBegin ? 1.0 : 0.0)
            : Curves.easeOut.transform(
                ((value - localBegin) / (localEnd - localBegin)).clamp(
                  0.0,
                  1.0,
                ),
              );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: Text(
              letters[i],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Kedipan glow lembut di belakang logo — reuse [WtGlowBlob] (blur di-render
/// SEKALI lewat parameter `child` pada [AnimatedBuilder], jadi setiap frame
/// hanya mengubah opacity/compositing, BUKAN menghitung ulang blur-nya.
class _PulseGlow extends StatelessWidget {
  final AnimationController loop;
  const _PulseGlow({required this.loop});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, child) {
        final breathe = (math.sin(loop.value * 2 * math.pi * 3) + 1) / 2;
        return Opacity(opacity: 0.35 + 0.35 * breathe, child: child);
      },
      child: const WtGlowBlob(size: 160, color: _kAccentGlow),
    );
  }
}

/// Tiga titik mengorbit lambat di sekeliling logo + cincin tipis statis —
/// murni [CustomPainter] (beberapa `drawCircle` per frame), dibungkus
/// [RepaintBoundary] supaya repaint-nya tidak ikut menggambar ulang teks di
/// bawahnya yang sudah statis setelah entrance selesai.
class _OrbitPainter extends CustomPainter {
  final double angle;
  const _OrbitPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    const dotCount = 3;
    for (var i = 0; i < dotCount; i++) {
      final a = angle + i * (2 * math.pi / dotCount);
      final offset = center + Offset(math.cos(a), math.sin(a)) * radius;
      final dotAlpha = 0.15 + 0.55 * ((math.sin(a) + 1) / 2);
      canvas.drawCircle(
        offset,
        3,
        Paint()..color = _kAccentGlow.withValues(alpha: dotAlpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.angle != angle;
}

/// Indikator muat pengganti `CircularProgressIndicator` generik — arc
/// pendek yang berputar terus mengikuti [loop], gaya spinner yang senada
/// dengan cincin orbit di atasnya alih-alih widget bawaan yang polos.
class _SpinningArc extends StatelessWidget {
  final AnimationController loop;
  const _SpinningArc({required this.loop});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(24, 24),
          painter: _ArcPainter(angle: loop.value * 2 * math.pi * 2),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double angle;
  const _ArcPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    canvas.drawArc(
      rect,
      angle,
      math.pi * 1.4,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
