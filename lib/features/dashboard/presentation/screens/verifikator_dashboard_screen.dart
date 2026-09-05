import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/theme/theme_provider.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/compliance/presentation/screens/consent_status_screen.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/users/presentation/screens/edit_profile_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/antrean_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/pencairan_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/riwayat_view.dart';
import 'package:wt_mobile/features/users/presentation/screens/notaris_public_key_screen.dart';

/// Shell screen untuk role Verifikator / Notaris.
class VerifikatorDashboardScreen extends ConsumerStatefulWidget {
  const VerifikatorDashboardScreen({super.key});

  @override
  ConsumerState<VerifikatorDashboardScreen> createState() =>
      _VerifikatorDashboardScreenState();
}

class _VerifikatorDashboardScreenState
    extends ConsumerState<VerifikatorDashboardScreen> {
  /// Mulai di Antrean — kini berada di slot tengah nav (yang terangkat),
  /// posisi paling mudah dijangkau ibu jari untuk destinasi utama Notaris.
  int _currentIndex = 1;

  static const _navItems = [
    WtBottomNavItem(
      id: 'pencairan',
      icon: Icons.receipt_long_outlined,
      iconFilled: Icons.receipt_long,
    ),
    WtBottomNavItem(
      id: 'antrean',
      icon: Icons.pending_actions_outlined,
      iconFilled: Icons.pending_actions,
    ),
    WtBottomNavItem(
      id: 'riwayat',
      icon: Icons.history_outlined,
      iconFilled: Icons.history,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Badge titik hijau di tab Antrean dulu SELALU tampil (showBadge: true
    // hardcode) walau antreannya kosong — sekarang dihitung dari data asli
    // (aset + relasi Non-Nasab pending) yang sama-sama ditampilkan di tab itu.
    final pendingAssets = ref.watch(pendingAssetsNotarisProvider).valueOrNull;
    final pendingFamily = ref.watch(pendingFamilyMembersProvider).valueOrNull;
    final pendingCount =
        (pendingAssets?.length ?? 0) + (pendingFamily?.length ?? 0);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const WtLogoWithText(title: 'Portal Notaris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Edit Profil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
            ),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: 'Ganti Tema',
            onPressed: () => ref.read(themeProvider.notifier).toggle(context),
          ),
          // Aksi yang lebih jarang dipakai dipindah ke sini — sebelumnya 5
          // IconButton (Edit Profil, Kunci PKI, Consent, tema, logout)
          // berjejer bareng judul di satu baris, berdesakan/judul terpepet
          // di layar sempit (~360dp).
          PopupMenuButton<void>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu Lainnya',
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotarisPublicKeyScreen(),
                  ),
                ),
                child: const ListTile(
                  leading: Icon(Icons.vpn_key_outlined),
                  title: Text('Kunci Enkripsi (PKI)'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<void>(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConsentStatusScreen(),
                  ),
                ),
                child: const ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('Persetujuan Data Pribadi'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<void>(
                onTap: () => ref.read(authProvider.notifier).logout(),
                child: const ListTile(
                  leading: Icon(Icons.logout, color: AppColors.danger),
                  title: Text(
                    'Keluar',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeIndexedStack(
        index: _currentIndex,
        // Urutan mengikuti _navItems: Pencairan — Antrean (tengah) — Riwayat.
        children: const [
          VerifikatorPencairanView(),
          VerifikatorAntreanView(),
          VerifikatorRiwayatView(),
        ],
      ),
      bottomNavigationBar: WtBottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        showBadge: pendingCount > 0,
        badgeIndex: 1,
      ),
    );
  }
}
