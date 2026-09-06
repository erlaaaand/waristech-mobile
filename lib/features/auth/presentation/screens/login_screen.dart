import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/theme/theme_provider.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Layar masuk.
///
/// Mengikuti panduan §3.1: setiap potongan UI adalah CLASS widget tersendiri,
/// bukan method `Widget _buildX()`. Dengan begitu tiap bagian punya
/// `BuildContext` sendiri, bisa `const`, dan tidak ikut dieksekusi ulang tiap
/// kali layar induk rebuild (mis. saat state loading berubah).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;

    await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.hasError) {
      _showError(authState.error.toString());
      return;
    }

    final user = authState.value;
    if (user != null) {
      // Routing terpusat via UserRole.dashboardRoute — tidak ada switch di UI
      context.goNamed(user.role.dashboardRoute);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    WtSnackbar.error(
      context,
      message,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    // Listen untuk error state
    ref.listen<AsyncValue<UserEntity?>>(authProvider, (_, next) {
      if (next.hasError) _showError(next.error.toString());
    });

    return WtAuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _LoginBranding(),
            const SizedBox(height: 40),
            WtAuthField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'Masukkan email terdaftar',
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            WtAuthField(
              label: 'Kata Sandi',
              controller: _passwordController,
              isPassword: true,
              hintText: 'Masukkan kata sandi',
              prefixIcon: const Icon(Icons.lock_outline),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Kata sandi tidak boleh kosong'
                  : null,
            ),
            const _ForgotPasswordLink(),
            const SizedBox(height: 24),
            WtAuthButton(
              label: 'Masuk',
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: 24),
            const _RegisterLink(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widget layar login
// ---------------------------------------------------------------------------

/// Blok identitas di atas form: wordmark kecil + headline besar rata-kiri +
/// subjudul — gaya tipografi mengikuti referensi (bukan lagi kartu logo
/// tersentris).
class _LoginBranding extends ConsumerWidget {
  const _LoginBranding();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                WtLogo(size: 26),
                SizedBox(width: 8),
                Text(
                  'WarisTech',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () => ref.read(themeProvider.notifier).toggle(context),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Selamat Datang\nKembali',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Masuk untuk mengakses Brankas Digital Anda',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : AppColors.navy.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.pushNamed('forgot-password'),
        child: Text(
          'Lupa Kata Sandi?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : AppColors.navy.withValues(alpha: 0.6),
          ),
        ),
        TextButton(
          // Ahli Waris TIDAK didaftarkan lewat sini — satu-satunya jalan
          // masuk resmi adalah link undangan yang dibuat Pewaris (lihat
          // `invitations_screen.dart` & `register_ahli_waris_screen.dart`).
          // Mendaftar tanpa kode dari link sudah pasti gagal di backend,
          // jadi tidak ditawarkan sebagai pilihan generik di sini.
          onPressed: () => context.pushNamed('register-pewaris'),
          child: Text(
            'Daftar Sekarang',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
