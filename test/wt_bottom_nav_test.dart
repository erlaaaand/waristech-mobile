import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

/// Regresi untuk tiga bug yang pernah terjadi pada [WtBottomNav]:
///
/// 1. Pembungkus terluar memakai `Center`. Scaffold mengukur slot
///    `bottomNavigationBar` dengan constraint tinggi LONGGAR, sehingga
///    `Center` memuai memenuhi layar dan pil nav tampak melayang di tengah
///    layar, bukan menempel di bawah.
/// 2. Bagian penanda aktif yang menonjol di atas pil digeser dengan
///    `Transform` DI DALAM area sentuh — terlihat menonjol tapi tidak bisa
///    ditekan, karena parent tidak meneruskan hit-test ke luar kotak layout
///    anaknya.
/// 3. Penanda aktif diam di posisi tengah, tidak ikut berpindah ke tab yang
///    sedang dibuka.
///
/// Semua assertion sengaja menguji PERILAKU yang terlihat pengguna (posisi
/// ikon, tinggi widget, respons sentuhan) — bukan struktur widget internal —
/// supaya tetap berlaku walau implementasinya diganti (mis. dari
/// `AnimatedPositioned` ke `CustomPaint`).
void main() {
  const items = [
    WtBottomNavItem(
      id: 'brankas',
      icon: Icons.shield_outlined,
      iconFilled: Icons.shield,
    ),
    WtBottomNavItem(
      id: 'beranda',
      icon: Icons.home_outlined,
      iconFilled: Icons.home,
    ),
    WtBottomNavItem(
      id: 'profil',
      icon: Icons.person_outline,
      iconFilled: Icons.person,
    ),
  ];

  Widget harness({
    int currentIndex = 1,
    ValueChanged<int>? onTap,
    bool showBadge = false,
    int? badgeIndex,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        extendBody: true,
        body: const SizedBox.expand(),
        bottomNavigationBar: WtBottomNav(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap ?? (_) {},
          showBadge: showBadge,
          badgeIndex: badgeIndex,
        ),
      ),
    );
  }

  void setScreen(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// Ikon tab aktif dikenali dari varian *filled*-nya.
  Finder activeIcon(int index) => find.byIcon(items[index].iconFilled);

  testWidgets('tingginya menyusut mengikuti isi, tidak memenuhi layar', (
    tester,
  ) async {
    setScreen(tester, const Size(400, 800));
    await tester.pumpWidget(harness());

    // Pil 64 + tonjolan + padding bawah 24 ≈ 110. Kalau widget ini memuai
    // memenuhi layar (bug lama), nilainya akan mendekati 800.
    expect(
      tester.getSize(find.byType(WtBottomNav)).height,
      lessThan(200),
      reason: 'WtBottomNav tidak boleh memuai setinggi layar',
    );
  });

  testWidgets('menempel di bagian bawah layar', (tester) async {
    setScreen(tester, const Size(400, 800));
    await tester.pumpWidget(harness());

    expect(
      tester.getRect(find.byType(WtBottomNav)).bottom,
      moreOrLessEquals(800, epsilon: 1),
      reason: 'sisi bawah nav harus menyentuh dasar layar',
    );
  });

  testWidgets('penanda aktif berpindah ke tab yang sedang dibuka', (
    tester,
  ) async {
    setScreen(tester, const Size(400, 800));

    await tester.pumpWidget(harness(currentIndex: 0));
    await tester.pumpAndSettle();
    final atFirst = tester.getRect(activeIcon(0)).center.dx;

    await tester.pumpWidget(harness(currentIndex: 1));
    await tester.pumpAndSettle();
    final atMiddle = tester.getRect(activeIcon(1)).center.dx;

    await tester.pumpWidget(harness(currentIndex: 2));
    await tester.pumpAndSettle();
    final atLast = tester.getRect(activeIcon(2)).center.dx;

    expect(
      atFirst,
      lessThan(atMiddle),
      reason: 'penanda harus bergeser ke kanan saat pindah tab 0 → 1',
    );
    expect(
      atMiddle,
      lessThan(atLast),
      reason: 'penanda harus bergeser ke kanan saat pindah tab 1 → 2',
    );
  });

  testWidgets('ikon tab aktif terangkat di atas ikon tab lain', (tester) async {
    setScreen(tester, const Size(400, 800));
    await tester.pumpWidget(harness(currentIndex: 1));
    await tester.pumpAndSettle();

    final activeY = tester.getRect(activeIcon(1)).center.dy;
    final inactiveY = tester.getRect(find.byIcon(items[0].icon)).center.dy;

    expect(
      activeY,
      lessThan(inactiveY - 8),
      reason: 'ikon tab aktif harus naik ke dalam tonjolan penanda',
    );
  });

  testWidgets('penanda menonjol di atas tepi pil', (tester) async {
    setScreen(tester, const Size(400, 800));
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    final navBottom = tester.getRect(find.byType(WtBottomNav)).bottom;
    // Pil setinggi 64 dengan padding bawah 24 → tepi atas pil ada di
    // navBottom - 88. Ikon tab aktif harus berada di ATAS garis itu.
    expect(tester.getRect(activeIcon(1)).top, lessThan(navBottom - 88));
  });

  testWidgets('setiap tab bisa ditekan, termasuk area penuh slotnya', (
    tester,
  ) async {
    setScreen(tester, const Size(400, 800));

    final tapped = <int>[];
    await tester.pumpWidget(harness(currentIndex: 1, onTap: tapped.add));

    await tester.tap(find.byIcon(items[0].icon));
    await tester.tap(find.byIcon(items[2].icon));
    await tester.pump();

    expect(tapped, [0, 2]);
  });

  testWidgets('tidak ada overflow pada layar sempit', (tester) async {
    setScreen(tester, const Size(320, 640));
    await tester.pumpWidget(harness());
    expect(tester.takeException(), isNull);
  });

  group('badge — jalur kode yang sempat rusak (isDark tidak terdefinisi)', () {
    // showBadge:true tidak pernah dites sebelumnya, jadi compile error
    // (referensi `isDark` yang tidak ada di scope `_NavItemState`, sempat
    // masuk ke file ini) tidak pernah ketahuan dari test suite — cuma dari
    // `flutter analyze`. Dites di TERANG & GELAP, dan pada tab yang aktif
    // maupun tidak aktif, supaya seluruh cabang warna cincin badge
    // (isActive ? putih : (isDark ? abu-gelap : hitam)) ikut ter-render.
    for (final brightness in Brightness.values) {
      for (final badgeOnActiveTab in [true, false]) {
        testWidgets(
          '$brightness, badge di tab ${badgeOnActiveTab ? "AKTIF" : "TIDAK aktif"} tidak crash',
          (tester) async {
            setScreen(tester, const Size(400, 800));
            await tester.pumpWidget(
              harness(
                currentIndex: 1,
                showBadge: true,
                badgeIndex: badgeOnActiveTab ? 1 : 0,
                brightness: brightness,
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('regresi: kurva hump di tab paling ujung', () {
    // Riwayat: bentuk pil+tonjolan dulu bezier manual dengan bahu/titik
    // kontrol yang dihitung dari koordinat mentah — 2x menyebabkan bug
    // geometri nyata (notch di sudut pil, lalu kurva "loop" jadi blob
    // terpisah) tiap kali konstanta layout (padding/lebar pil) diubah,
    // karena titik kontrolnya harus di-tune ulang manual. Sekarang dibangun
    // dari `Path.combine(PathOperation.union, ...)` (pil + lingkaran) yang
    // valid untuk posisi indikator mana pun tanpa kasus-khusus tepi sama
    // sekali. Test ini dipertahankan sebagai regression-guard umum — dites
    // dengan 3 ITEM (pil 220px, prototipe) dan 4 ITEM (pil 288px, dashboard
    // Ahli Waris) supaya kedua cabang lebar pil ikut ter-cover.
    const fourItems = [
      WtBottomNavItem(id: 'a', icon: Icons.home_outlined, iconFilled: Icons.home),
      WtBottomNavItem(
        id: 'b',
        icon: Icons.upload_file_outlined,
        iconFilled: Icons.upload_file,
      ),
      WtBottomNavItem(id: 'c', icon: Icons.policy_outlined, iconFilled: Icons.policy),
      WtBottomNavItem(id: 'd', icon: Icons.lock_outline, iconFilled: Icons.lock),
    ];

    Widget edgeHarness(List<WtBottomNavItem> navItems, int currentIndex) {
      return MaterialApp(
        home: Scaffold(
          extendBody: true,
          body: const SizedBox.expand(),
          bottomNavigationBar: WtBottomNav(
            items: navItems,
            currentIndex: currentIndex,
            onTap: (_) {},
          ),
        ),
      );
    }

    for (final currentIndex in [0, 2]) {
      testWidgets('3 item, tab index $currentIndex tidak crash/overflow', (
        tester,
      ) async {
        setScreen(tester, const Size(360, 800));
        await tester.pumpWidget(edgeHarness(items, currentIndex));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    for (final currentIndex in [0, 3]) {
      testWidgets('4 item, tab index $currentIndex tidak crash/overflow', (
        tester,
      ) async {
        setScreen(tester, const Size(360, 800));
        await tester.pumpWidget(edgeHarness(fourItems, currentIndex));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
