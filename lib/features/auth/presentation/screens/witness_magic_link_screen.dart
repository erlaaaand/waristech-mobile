import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/auth/presentation/screens/witness_decision_screen.dart';

/// Alur Guest (Saksi) dari tautan email — DI LUAR shell dashboard biasa.
/// Backend: POST /auth/magic-link/verify ({token, otp}) — token & OTP
/// sekali pakai, sesi Guest berlaku 1 hari.
class WitnessMagicLinkScreen extends ConsumerStatefulWidget {
  final String token;
  const WitnessMagicLinkScreen({super.key, required this.token});

  @override
  ConsumerState<WitnessMagicLinkScreen> createState() =>
      _WitnessMagicLinkScreenState();
}

class _WitnessMagicLinkScreenState
    extends ConsumerState<WitnessMagicLinkScreen> {
  final _otpCtrl = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Kode OTP harus 6 digit.');
      return;
    }
    if (widget.token.isEmpty) {
      setState(() => _error = 'Tautan tidak valid — token tidak ditemukan.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    await ref
        .read(authProvider.notifier)
        .verifyMagicLink(token: widget.token, otp: otp);
    if (!mounted) return;
    setState(() => _isVerifying = false);

    final authState = ref.read(authProvider);
    if (authState.hasError) {
      setState(() => _error = authState.error.toString());
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const WitnessDecisionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Saksi')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Masukkan Kode OTP',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kode OTP 6 digit telah dikirim ke email Anda bersama tautan ini.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.gray500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Verifikasi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
