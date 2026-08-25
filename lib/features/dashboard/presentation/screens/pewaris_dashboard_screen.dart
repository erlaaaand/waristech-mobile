import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/theme/theme_provider.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/aset_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/home_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/hukum_waris_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/profil_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/pewaris/protokol_view.dart';

/// Shell screen untuk role Pewaris.
/// Bertanggung jawab atas: AppBar, BottomNav, dan IndexedStack.
/// Semua logika UI ada di dalam views masing-masing.
class PewarisDashboardScreen extends ConsumerStatefulWidget {
  const PewarisDashboardScreen({super.key});

  @override
  ConsumerState<PewarisDashboardScreen> createState() =>
      _PewarisDashboardScreenState();
}

class _PewarisDashboardScreenState
    extends ConsumerState<PewarisDashboardScreen> {
  int _currentIndex = 0;

  static const _navItems = [
    WtBottomNavItem(id: 'beranda',      icon: Icons.dashboard_outlined,               iconFilled: Icons.dashboard),
    WtBottomNavItem(id: 'aset',         icon: Icons.account_balance_wallet_outlined,  iconFilled: Icons.account_balance_wallet),
    WtBottomNavItem(id: 'hukum-waris', icon: Icons.gavel_outlined,                   iconFilled: Icons.gavel),
    WtBottomNavItem(id: 'protokol',    icon: Icons.verified_user_outlined,            iconFilled: Icons.verified_user),
    WtBottomNavItem(id: 'profil',      icon: Icons.person_outline,                   iconFilled: Icons.person),
  ];

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const WtLogoWithText(title: 'WarisTech'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggle(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              backgroundColor: isDark ? Colors.white : AppColors.navy,
              foregroundColor: isDark ? AppColors.navy : Colors.white,
              radius: 16,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PewarisHomeView(onNavigate: _navigate),
          const PewarisAsetView(),
          const PewarisHukumWarisView(),
          const PewarisProtokolView(),
          const PewarisProfilView(),
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
