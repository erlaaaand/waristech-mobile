import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/aset_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/home_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/profil_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/protokol_view.dart';
import 'package:wt_mobile/features/inheritance/presentation/screens/invitations_screen.dart';

/// Shell screen untuk role Pewaris.
///
/// Navigasi mengikuti prototipe `index.html`: TIGA tab dalam pil hitam
/// mengambang (Brankas — Beranda di tengah & terangkat — Profil). Protokol
/// Darurat bukan tab, melainkan halaman yang dibuka dari kartu Ringkasan di
/// Beranda dan dari daftar di tab Profil — memaksakan ikon tambahan ke dalam
/// pil selebar 220px akan berdesakan dan merusak bentuk nav yang jadi ciri
/// khas desainnya.
class PewarisDashboardScreen extends ConsumerStatefulWidget {
  const PewarisDashboardScreen({super.key});

  @override
  ConsumerState<PewarisDashboardScreen> createState() =>
      _PewarisDashboardScreenState();
}

class _PewarisDashboardScreenState
    extends ConsumerState<PewarisDashboardScreen> {
  /// Mulai di Beranda (indeks tengah), sama seperti prototipe.
  int _currentIndex = 1;

  static const _navItems = [
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

  void _navigate(int index) => setState(() => _currentIndex = index);

  void _openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      // Prototipe tidak punya top app bar terpisah — baris sapaan/judul
      // adalah bagian dari konten yang ikut scroll di tiap tab. Karena tidak
      // ada AppBar yang biasanya menyisihkan area status bar, konten WAJIB
      // dibungkus SafeArea (atas saja) agar sapaan tidak tertimpa jam/ikon
      // sistem. `bottom: false` supaya konten tetap bisa scroll ke belakang
      // nav mengambang.
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: FadeIndexedStack(
          index: _currentIndex,
          children: [
            const PewarisAsetView(),
            PewarisHomeView(
              onOpenAssets: () => _navigate(0),
              onOpenProfile: () => _navigate(2),
              onOpenHeirs: () => _openPage(const InvitationsScreen()),
              onOpenProtocol: () => _openPage(const PewarisProtokolPage()),
            ),
            PewarisProfilView(
              onOpenProtocol: () => _openPage(const PewarisProtokolPage()),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WtBottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _navigate,
      ),
    );
  }
}

/// Pembungkus halaman (bukan tab) untuk Protokol Darurat.
class PewarisProtokolPage extends StatelessWidget {
  const PewarisProtokolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontak Darurat')),
      body: const PewarisProtokolView(),
    );
  }
}

