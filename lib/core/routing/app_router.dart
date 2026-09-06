import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:wt_mobile/features/auth/presentation/screens/register_pewaris_screen.dart';
import 'package:wt_mobile/features/auth/presentation/screens/register_ahli_waris_screen.dart';
import 'package:wt_mobile/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:wt_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:wt_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:wt_mobile/features/auth/presentation/screens/witness_magic_link_screen.dart';
import 'package:wt_mobile/features/assets/domain/entities/create_asset_result_entity.dart';
import 'package:wt_mobile/features/assets/presentation/screens/create_asset_screen.dart';
import 'package:wt_mobile/features/assets/presentation/screens/share_reveal_screen.dart';
import 'package:wt_mobile/features/inheritance/presentation/screens/invitations_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/screens/ahli_waris_dashboard_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/screens/pewaris_dashboard_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/screens/verifikator_dashboard_screen.dart';
import 'package:wt_mobile/features/splash/presentation/screens/splash_screen.dart';

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
      // Rute alur login/registrasi — boleh diakses TANPA sesi aktif, tapi
      // begitu sudah login harus diarahkan pergi (bukan tempat yang relevan).
      const authOnlyPublicRoutes = {
        '/login',
        '/register/pewaris',
        '/register/ahli-waris',
        '/verify-email',
        '/forgot-password',
        '/reset-password',
      };
      // Rute alur Guest (Saksi via magic link) — di luar shell dashboard.
      // Boleh diakses TANPA sesi aktif (baru mau verifikasi OTP) DAN TETAP
      // boleh diakses SETELAH sesi Guest terbentuk (lanjut ke keputusan) —
      // Guest.dashboardRoute jatuh ke 'login' sehingga tidak boleh dianggap
      // sebagai rute yang harus "dibuang" begitu login seperti authOnlyPublicRoutes.
      const guestFlowRoutes = {'/verifikasi/saksi'};

      final path = state.uri.path;
      final isAuthOnlyPublic = authOnlyPublicRoutes.contains(path);
      final isGuestFlow = guestFlowRoutes.contains(path);

      // Belum login dan bukan di rute publik (auth ATAU guest) -> ke login
      if (user == null && !isAuthOnlyPublic && !isGuestFlow) return '/login';

      // Sudah login tapi masih di rute auth-only -> arahkan ke dashboard
      if (user != null && isAuthOnlyPublic) {
        return '/${user.role.dashboardRoute}';
      }

      // Rute Guest tidak pernah di-redirect pergi, baik sebelum maupun
      // sesudah sesi Guest terbentuk.
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
              if (authState.isLoading) return const SplashScreen();
              return const LoginScreen();
            },
          );
        },
      ),
      GoRoute(
        path: '/register/pewaris',
        name: 'register-pewaris',
        builder: (_, _) => const RegisterPewarisScreen(),
      ),
      GoRoute(
        path: '/register/ahli-waris',
        name: 'register-ahli-waris',
        // `kode` diisi otomatis saat rute ini dibuka lewat link undangan
        // Pewaris (lihat `buildInvitationLink` di backend) — bukan lagi
        // opsi generik yang ditampilkan di layar login.
        builder: (_, state) => RegisterAhliWarisScreen(
          initialInvitationCode: state.uri.queryParameters['kode'],
        ),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (_, state) =>
            VerifyEmailScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (_, state) =>
            ResetPasswordScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/verifikasi/saksi',
        name: 'verifikasi-saksi',
        builder: (_, state) => WitnessMagicLinkScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: '/pewaris-dashboard',
        name: 'pewaris-dashboard',
        builder: (_, _) => const PewarisDashboardScreen(),
      ),
      GoRoute(
        path: '/assets/create',
        name: 'create-asset',
        builder: (_, _) => const CreateAssetScreen(),
      ),
      GoRoute(
        path: '/assets/share-reveal',
        name: 'share-reveal',
        builder: (_, state) =>
            ShareRevealScreen(result: state.extra as CreateAssetResultEntity),
      ),
      GoRoute(
        path: '/invitations',
        name: 'invitations',
        builder: (_, _) => const InvitationsScreen(),
      ),
      GoRoute(
        path: '/ahli-waris-dashboard',
        name: 'ahli-waris-dashboard',
        builder: (_, _) => const AhliWarisDashboardScreen(),
      ),
      GoRoute(
        path: '/verifikator-dashboard',
        name: 'verifikator-dashboard',
        builder: (_, _) => const VerifikatorDashboardScreen(),
      ),
    ],
  );
});

/// [ChangeNotifier] adapter untuk menghubungkan [StateNotifier] Riverpod
/// dengan [GoRouter.refreshListenable].
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(StateNotifier<Object?> notifier) {
    notifier.addListener((_) => notifyListeners());
  }
}

// Widget splash sesungguhnya ada di `SplashScreen`
// (lib/features/splash/presentation/screens/splash_screen.dart) — dipakai
// juga sebagai handoff visual dari splash native (flutter_native_splash).
