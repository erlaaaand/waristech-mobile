import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/theme/theme_provider.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/compliance/presentation/screens/consent_status_screen.dart';
import 'package:wt_mobile/features/users/presentation/screens/edit_profile_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/brankas_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/home_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/lacak_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/ahli_waris/lapor_view.dart';

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
  ];

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const WtLogoWithText(title: 'Portal Ahli Waris'),
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
          // Aksi yang lebih jarang dipakai dipindah ke sini — sebelumnya 4
          // IconButton berjejer bareng judul di satu baris, berdesakan di
          // layar sempit (~360dp).
          PopupMenuButton<void>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu Lainnya',
            itemBuilder: (context) => [
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
        children: [
          AhliWarisHomeView(onNavigate: _navigate),
          const AhliWarisLaporView(),
          const AhliWarisLacakView(),
          const AhliWarisBrankasView(),
        ],
      ),
      bottomNavigationBar: WtBottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _navigate,
      ),
    );
  }
}
