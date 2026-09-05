import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Registrasi Ahli Waris (Closed-Loop / Invitation).
/// Backend: POST /auth/register/ahli-waris — butuh kode undangan valid dari
/// Pewaris. Akun dibuat NON-AKTIF, OTP dikirim ke email.
///
/// Rute INI TIDAK ditampilkan sebagai pilihan generik di layar login — satu-
/// satunya jalan masuk resmi adalah link undangan yang dibuat Pewaris
/// (lihat `invitations_screen.dart`), yang mengisi [initialInvitationCode]
/// otomatis lewat query parameter `?kode=` (lihat `app_router.dart`).
class RegisterAhliWarisScreen extends ConsumerStatefulWidget {
  final String? initialInvitationCode;
  const RegisterAhliWarisScreen({super.key, this.initialInvitationCode});

  @override
  ConsumerState<RegisterAhliWarisScreen> createState() =>
      _RegisterAhliWarisScreenState();
}

class _RegisterAhliWarisScreenState
    extends ConsumerState<RegisterAhliWarisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late final TextEditingController _invitationCtrl;
  final _passwordCtrl = TextEditingController();
  bool _consentAgreed = false;

  @override
  void initState() {
    super.initState();
    _invitationCtrl = TextEditingController(
      text: widget.initialInvitationCode?.toUpperCase() ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _invitationCtrl.dispose();
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
        .registerAhliWaris(
          email: email,
          password: _passwordCtrl.text,
          fullName: _fullNameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          invitationCode: _invitationCtrl.text.trim().toUpperCase(),
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
              title: 'Daftar sebagai Ahli Waris',
              subtitle:
                  'Daftar menggunakan kode undangan yang diberikan Pewaris Anda.',
            ),
            const SizedBox(height: 24),
            if (widget.initialInvitationCode != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kode undangan terisi otomatis dari link.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            WtAuthField(
              label: 'Kode Undangan',
              controller: _invitationCtrl,
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Kode undangan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            WtAuthField(
              label: 'Nama Lengkap',
              controller: _fullNameCtrl,
              prefixIcon: const Icon(Icons.person_outline),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama lengkap wajib diisi'
                  : null,
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
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nomor telepon wajib diisi'
                  : null,
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
                  'Saya menyetujui pemrosesan data pribadi sesuai UU No. 27 Tahun 2022 '
                  'tentang Pelindungan Data Pribadi.',
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
}
