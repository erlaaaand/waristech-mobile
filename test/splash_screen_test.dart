import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wt_mobile/features/splash/presentation/screens/splash_screen.dart';

/// Tidak ada emulator/device untuk verifikasi visual splash yang baru
/// (2 `AnimationController`, beberapa `CustomPainter`, `Listenable.merge`),
/// jadi tes ini setidaknya memastikan seluruh animasi — entrance staggered
/// maupun idle-loop dekoratif — berjalan sekian frame TANPA exception,
/// dan aman saat widget dilepas (auth selesai loading) di tengah animasi.
void main() {
  testWidgets('SplashScreen animates end-to-end tanpa exception', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // Lewati seluruh durasi entrance (1600ms) dalam langkah kecil supaya
    // tiap tahap staggering (logo, orbit, wordmark, tagline, loading arc)
    // benar-benar dieksekusi, bukan cuma awal/akhir.
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }

    // Beberapa siklus idle-loop (repeat 6 detik) — orbit, arc pemuat, dan
    // kedipan glow tetap aman berjalan terus setelah entrance selesai.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    }

    // Wordmark "WarisTech" akhirnya tampil utuh, huruf demi huruf.
    for (final letter in 'WarisTech'.split('')) {
      expect(find.text(letter), findsWidgets);
    }
  });

  testWidgets('SplashScreen aman dilepas di tengah animasi (auth selesai lebih cepat)', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
