import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/brankas_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/home_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/lacak_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/lapor_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/profil_view.dart';

/// Shell screen untuk role Ahli Waris.
class AhliWarisDashboardScreen extends ConsumerStatefulWidget {
  const AhliWarisDashboardScreen({super.key});

  @override
  ConsumerState<AhliWarisDashboardScreen> createState() =>
      _AhliWarisDashboardScreenState();
}

class _AhliWarisDashboardScreenState
    extends ConsumerState<AhliWarisDashboardScreen> {
  int _currentIndex = 0;

  static const _navItems = [
    WtBottomNavItem(
      id: 'beranda',
      icon: Icons.dashboard_outlined,
      iconFilled: Icons.dashboard,
    ),
    WtBottomNavItem(
      id: 'lapor',
      icon: Icons.upload_file_outlined,
      iconFilled: Icons.upload_file,
    ),
    WtBottomNavItem(
      id: 'lacak',
      icon: Icons.policy_outlined,
      iconFilled: Icons.policy,
    ),
    WtBottomNavItem(
      id: 'brankas',
      icon: Icons.lock_outline,
      iconFilled: Icons.lock,
    ),
    WtBottomNavItem(
      id: 'profil',
      icon: Icons.person_outline,
      iconFilled: Icons.person,
    ),
  ];

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      // Sama seperti PewarisDashboardScreen: tidak ada AppBar terpisah —
      // pengaturan (Edit Profil/Tema/Consent/Keluar) pindah ke tab Profil.
      // SafeArea(top) WAJIB di sini karena tidak ada AppBar yang biasanya
      // menyisihkan area status bar.
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: FadeIndexedStack(
          index: _currentIndex,
          children: [
            AhliWarisHomeView(onNavigate: _navigate),
            const AhliWarisLaporView(),
            const AhliWarisLacakView(),
            const AhliWarisBrankasView(),
            const AhliWarisProfilView(),
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
