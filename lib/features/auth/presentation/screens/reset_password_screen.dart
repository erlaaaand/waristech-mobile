import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Tukar OTP reset password dengan password baru — POST /auth/reset-password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _otp = '';

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_otp.length != 6) {
      WtSnackbar.error(context, 'Kode OTP harus 6 digit.');
      return;
    }

    await ref
        .read(resetPasswordProvider.notifier)
        .submit(email: widget.email, otp: _otp, newPassword: _passwordCtrl.text);
    if (!mounted) return;

    final state = ref.read(resetPasswordProvider);
    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
      return;
    }

    WtSnackbar.success(
      context,
      state.value ?? 'Password berhasil direset. Silakan masuk kembali.',
      backgroundColor: AppColors.success,
    );
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(resetPasswordProvider).isLoading;

    return WtAuthScaffold(
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WtAuthHeader(
              title: 'Buat Kata Sandi Baru',
              subtitle:
                  'Masukkan kode OTP yang dikirim ke ${widget.email} beserta '
                  'kata sandi baru Anda.',
            ),
            const SizedBox(height: 28),
            WtOtpField(
              label: 'Kode OTP',
              onChanged: (value) => setState(() => _otp = value),
            ),
            const SizedBox(height: 20),
            WtAuthField(
              label: 'Kata Sandi Baru',
              controller: _passwordCtrl,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Minimal 8 karakter',
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Kata sandi baru tidak boleh kosong';
                }
                if (v.length < 8) return 'Minimal 8 karakter';
                final hasUpper = v.contains(RegExp('[A-Z]'));
                final hasLower = v.contains(RegExp('[a-z]'));
                final hasDigit = v.contains(RegExp('[0-9]'));
                if (!hasUpper || !hasLower || !hasDigit) {
                  return 'Harus mengandung huruf besar, kecil, dan angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            WtAuthField(
              label: 'Konfirmasi Kata Sandi Baru',
              controller: _confirmCtrl,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Ulangi kata sandi baru',
              validator: (v) =>
                  v != _passwordCtrl.text ? 'Kata sandi tidak sama' : null,
            ),
            const SizedBox(height: 24),
            WtAuthButton(
              label: 'Reset Kata Sandi',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
