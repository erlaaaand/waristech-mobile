import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/theme/theme_provider.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
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
    WtBottomNavItem(id: 'beranda', icon: Icons.dashboard_outlined,    iconFilled: Icons.dashboard),
    WtBottomNavItem(id: 'lapor',   icon: Icons.upload_file_outlined,  iconFilled: Icons.upload_file),
    WtBottomNavItem(id: 'lacak',   icon: Icons.policy_outlined,       iconFilled: Icons.policy),
    WtBottomNavItem(id: 'brankas', icon: Icons.lock_outline,          iconFilled: Icons.lock),
  ];

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const WtLogoWithText(title: 'Portal Ahli Waris'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggle(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.danger),
            onPressed: () async => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: IndexedStack(
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
