import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/screens/ahli_waris_dashboard_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/screens/pewaris_dashboard_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/screens/verifikator_dashboard_screen.dart';

/// Provider router agar bisa mengakses [authProvider] untuk redirect.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final user = authState.valueOrNull;
      final isOnLogin = state.matchedLocation == '/login';

      // Jika belum login dan bukan di halaman login, arahkan ke login
      if (user == null && !isOnLogin) return '/login';

      // Jika sudah login tapi masih di halaman login, arahkan ke dashboard
      if (user != null && isOnLogin) {
        // Delegasikan ke UserRole.dashboardRoute — tidak ada logika duplikat
        return '/${user.role.dashboardRoute}';
      }
      return null;
    },
    refreshListenable: _AuthStateListenable(authNotifier),
    routes: [
      GoRoute(path: '/login',                 name: 'login',                  builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/pewaris-dashboard',     name: 'pewaris-dashboard',      builder: (_, __) => const PewarisDashboardScreen()),
      GoRoute(path: '/ahli-waris-dashboard',  name: 'ahli-waris-dashboard',   builder: (_, __) => const AhliWarisDashboardScreen()),
      GoRoute(path: '/verifikator-dashboard', name: 'verifikator-dashboard',  builder: (_, __) => const VerifikatorDashboardScreen()),
    ],
  );
});

/// [ChangeNotifier] adapter untuk menghubungkan [StateNotifier] Riverpod
/// dengan [GoRouter.refreshListenable].
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(StateNotifier notifier) {
    notifier.addListener((_) => notifyListeners());
  }
}
