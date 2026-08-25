import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/theme/theme_provider.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/views/verifikator/antrean_view.dart';
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
  int _currentIndex = 0;

  static const _navItems = [
    WtBottomNavItem(id: 'antrean', icon: Icons.pending_actions_outlined, iconFilled: Icons.pending_actions),
    WtBottomNavItem(id: 'riwayat', icon: Icons.history_outlined,         iconFilled: Icons.history),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const WtLogoWithText(title: 'Portal Notaris'),
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
        children: const [
          VerifikatorAntreanView(),
          VerifikatorRiwayatView(),
        ],
      ),
      bottomNavigationBar: WtBottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        showBadge: true,
        badgeIndex: 0,
      ),
    );
  }
}
