import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/utils/phone_number_utils.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Registrasi Pewaris (Self-Service).
/// Backend: POST /auth/register/pewaris — akun dibuat NON-AKTIF, OTP dikirim
/// ke email. Consent UU PDP wajib dicentang (backend menolak 400 jika tidak).
class RegisterPewarisScreen extends ConsumerStatefulWidget {
  const RegisterPewarisScreen({super.key});

  @override
  ConsumerState<RegisterPewarisScreen> createState() =>
      _RegisterPewarisScreenState();
}

class _RegisterPewarisScreenState extends ConsumerState<RegisterPewarisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _consentAgreed = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nikCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (!_consentAgreed) {
      _showSnack(
        'Anda wajib menyetujui pemrosesan data pribadi (UU PDP) untuk mendaftar.',
        isError: true,
      );
      return;
    }

    final email = _emailCtrl.text.trim();
    await ref
        .read(registerProvider.notifier)
        .registerPewaris(
          email: email,
          password: _passwordCtrl.text,
          fullName: _fullNameCtrl.text.trim(),
          phoneNumber:
              PhoneNumberUtils.normalize(_phoneCtrl.text.trim()) ??
                  _phoneCtrl.text.trim(),
          nik: _nikCtrl.text.trim(),
          consentAgreed: _consentAgreed,
        );

    if (!mounted) return;
    final state = ref.read(registerProvider);
    if (state.hasError) {
      _showSnack(state.error.toString(), isError: true);
      return;
    }

    _showSnack('Registrasi berhasil. Kode OTP dikirim ke email Anda.');
    context.pushNamed('verify-email', extra: email);
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
    final isLoading = ref.watch(registerProvider).isLoading;

    return WtAuthScaffold(
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WtAuthHeader(
              title: 'Daftar sebagai Pewaris',
              subtitle:
                  'Akun Pewaris digunakan untuk mendaftarkan aset digital '
                  '& merencanakan pembagian warisan.',
            ),
            const SizedBox(height: 28),
            WtAuthField(
              label: 'Nama Lengkap',
              controller: _fullNameCtrl,
              prefixIcon: const Icon(Icons.person_outline),
              validator: _requiredValidator('Nama lengkap'),
            ),
            const SizedBox(height: 16),
            WtAuthField(
              label: 'Email',
              controller: _emailCtrl,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            WtAuthField(
              label: 'Nomor WhatsApp',
              controller: _phoneCtrl,
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              hintText: '081234567890',
              validator: PhoneNumberUtils.validator,
            ),
            const SizedBox(height: 16),
            WtAuthField(
              label: 'NIK (16 digit)',
              controller: _nikCtrl,
              prefixIcon: const Icon(Icons.badge_outlined),
              keyboardType: TextInputType.number,
              maxLength: 16,
              validator: (v) {
                if (v == null || v.isEmpty) return 'NIK wajib diisi';
                if (!RegExp(r'^\d{16}$').hasMatch(v)) {
                  return 'NIK harus persis 16 digit angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            WtAuthField(
              label: 'Kata Sandi',
              controller: _passwordCtrl,
              prefixIcon: const Icon(Icons.lock_outline),
              isPassword: true,
              validator: (v) {
                if (v == null || v.length < 8) {
                  return 'Kata sandi minimal 8 karakter';
                }
                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                    .hasMatch(v)) {
                  return 'Wajib mengandung huruf besar, kecil, dan angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            WtConsentCheckbox(
              value: _consentAgreed,
              onChanged: (v) => setState(() => _consentAgreed = v),
              text:
                  'Saya menyetujui pemrosesan data pribadi (termasuk data keuangan) '
                  'sesuai UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi.',
            ),
            const SizedBox(height: 28),
            WtAuthButton(
              label: 'Daftar',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String label) {
    return (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;
  }
}
