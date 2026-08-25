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

      // Jangan redirect saat sedang cek session (loading = splash screen)
      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final isOnLogin = state.matchedLocation == '/login';

      // Jika belum login dan bukan di halaman login, arahkan ke login
      if (user == null && !isOnLogin) return '/login';

      // Jika sudah login tapi masih di halaman login, arahkan ke dashboard
      if (user != null && isOnLogin) {
        return '/${user.role.dashboardRoute}';
      }
      return null;
    },
    refreshListenable: _AuthStateListenable(authNotifier),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, state) {
          // Jika authProvider masih loading, tampilkan splash
          return Consumer(
            builder: (ctx, ref, _) {
              final authState = ref.watch(authProvider);
              if (authState.isLoading) return const _SplashScreen();
              return const LoginScreen();
            },
          );
        },
      ),
      GoRoute(
        path: '/pewaris-dashboard',
        name: 'pewaris-dashboard',
        builder: (_, __) => const PewarisDashboardScreen(),
      ),
      GoRoute(
        path: '/ahli-waris-dashboard',
        name: 'ahli-waris-dashboard',
        builder: (_, __) => const AhliWarisDashboardScreen(),
      ),
      GoRoute(
        path: '/verifikator-dashboard',
        name: 'verifikator-dashboard',
        builder: (_, __) => const VerifikatorDashboardScreen(),
      ),
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

/// Splash screen sederhana selama cek session.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('WarisTech',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
