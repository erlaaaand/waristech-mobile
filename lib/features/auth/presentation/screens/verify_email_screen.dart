import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Verifikasi OTP email setelah registrasi.
/// Backend: POST /auth/verify-email — sukses langsung membentuk sesi
/// (akun aktif + login), sehingga memakai [authProvider], bukan [registerProvider].
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  String _otp = '';
  Timer? _resendTimer;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 1) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _submit() async {
    if (_otp.length != 6) {
      _showSnack('Kode OTP harus 6 digit.', isError: true);
      return;
    }

    await ref.read(authProvider.notifier).verifyEmail(widget.email, _otp);
    if (!mounted) return;

    final state = ref.read(authProvider);
    if (state.hasError) {
      _showSnack(state.error.toString(), isError: true);
      return;
    }
    // Routing ke dashboard sepenuhnya ditangani oleh redirect guard di
    // app_router.dart begitu authProvider berisi UserEntity — tidak perlu
    // navigasi manual di sini.
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    await ref.read(registerProvider.notifier).resendOtp(widget.email);
    if (!mounted) return;
    final state = ref.read(registerProvider);
    if (state.hasError) {
      _showSnack(state.error.toString(), isError: true);
      return;
    }
    _showSnack('Kode OTP baru telah dikirim.');
    _startResendCooldown();
  }

  void _showSnack(String message, {bool isError = false}) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    if (isError) {
      WtSnackbar.error(context, message, shape: shape);
    } else {
      WtSnackbar.success(
        context,
        message,
        shape: shape,
        backgroundColor: AppColors.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(authProvider).isLoading;

    ref.listen<AsyncValue<UserEntity?>>(authProvider, (_, next) {
      if (next.hasError) _showSnack(next.error.toString(), isError: true);
    });

    return WtAuthScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WtAuthHeader(
            title: 'Verifikasi Email',
            subtitle: 'Kami telah mengirim kode 6 digit ke ${widget.email}.',
          ),
          const SizedBox(height: 28),
          WtOtpField(onChanged: (value) => setState(() => _otp = value)),
          const SizedBox(height: 24),
          WtAuthButton(
            label: 'Verifikasi',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _resendCooldown > 0 ? null : _resend,
              child: Text(
                _resendCooldown > 0
                    ? 'Kirim ulang dalam ${_resendCooldown}s'
                    : 'Kirim Ulang Kode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
