import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Minta OTP reset password — POST /auth/forgot-password.
/// Backend selalu mengembalikan pesan generik (anti-enumeration), jadi
/// layar ini TIDAK bisa/tidak boleh mengonfirmasi apakah email terdaftar.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    final email = _emailCtrl.text.trim();

    await ref.read(forgotPasswordProvider.notifier).submit(email);
    if (!mounted) return;

    final state = ref.read(forgotPasswordProvider);
    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
      return;
    }

    context.pushNamed('reset-password', extra: email);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(forgotPasswordProvider).isLoading;

    return WtAuthScaffold(
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WtAuthHeader(
              title: 'Reset Kata Sandi',
              subtitle:
                  'Masukkan email akun Anda. Jika terdaftar, kami akan '
                  'mengirimkan kode OTP untuk membuat kata sandi baru.',
            ),
            const SizedBox(height: 28),
            WtAuthField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              hintText: 'Masukkan email terdaftar',
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 24),
            WtAuthButton(
              label: 'Kirim Kode OTP',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
