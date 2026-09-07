import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/antrean_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/pencairan_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/profil_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/riwayat_view.dart';

/// Shell screen untuk role Verifikator / Notaris.
class VerifikatorDashboardScreen extends ConsumerStatefulWidget {
  const VerifikatorDashboardScreen({super.key});

  @override
  ConsumerState<VerifikatorDashboardScreen> createState() =>
      _VerifikatorDashboardScreenState();
}

class _VerifikatorDashboardScreenState
    extends ConsumerState<VerifikatorDashboardScreen> {
  /// Mulai di Antrean — destinasi utama Notaris saat membuka app.
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
    WtBottomNavItem(
      id: 'profil',
      icon: Icons.person_outline,
      iconFilled: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Badge titik hijau di tab Antrean dulu SELALU tampil (showBadge: true
    // hardcode) walau antreannya kosong — sekarang dihitung dari data asli
    // (aset + relasi Non-Nasab + akta kematian pending) yang sama-sama
    // ditampilkan di tab itu.
    final pendingAssets = ref.watch(pendingAssetsNotarisProvider).valueOrNull;
    final pendingFamily = ref.watch(pendingFamilyMembersProvider).valueOrNull;
    final pendingDeathCerts = ref
        .watch(pendingDeathCertificatesProvider)
        .valueOrNull;
    final pendingCount =
        (pendingAssets?.length ?? 0) +
        (pendingFamily?.length ?? 0) +
        (pendingDeathCerts?.length ?? 0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      // Sama seperti PewarisDashboardScreen: tidak ada AppBar terpisah —
      // pengaturan (Edit Profil/Tema/Kunci PKI/Consent/Keluar) pindah ke tab
      // Profil. SafeArea(top) WAJIB di sini karena tidak ada AppBar yang
      // biasanya menyisihkan area status bar.
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: FadeIndexedStack(
          index: _currentIndex,
          // Urutan mengikuti _navItems: Pencairan — Antrean — Riwayat — Profil.
          children: [
            const VerifikatorPencairanView(),
            VerifikatorAntreanView(
              onOpenProfile: () => setState(() => _currentIndex = 3),
            ),
            const VerifikatorRiwayatView(),
            const VerifikatorProfilView(),
          ],
        ),
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
