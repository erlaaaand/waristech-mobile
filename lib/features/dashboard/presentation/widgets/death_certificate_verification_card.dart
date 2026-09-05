import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';

class DeathCertificateVerificationCard extends ConsumerStatefulWidget {
  const DeathCertificateVerificationCard({super.key});

  @override
  ConsumerState<DeathCertificateVerificationCard> createState() =>
      _DeathCertificateVerificationCardState();
}

class _DeathCertificateVerificationCardState
    extends ConsumerState<DeathCertificateVerificationCard> {
  final _idCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final id = _idCtrl.text.trim();
    if (id.isEmpty) return;
    await ref.read(verifyDeathCertificateProvider.notifier).verify(id);
    if (!mounted) return;
    final state = ref.read(verifyDeathCertificateProvider);
    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
      return;
    }
    _idCtrl.clear();
    WtSnackbar.success(context, 'Dokumen akta kematian terverifikasi.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(verifyDeathCertificateProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : AppColors.navy).withValues(
            alpha: 0.05,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verifikasi Akta Kematian',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Masukkan ID Verifikasi Kematian yang diajukan keluarga Pewaris.',
            style: TextStyle(
              fontSize: 12,
              color: (isDark ? Colors.white : AppColors.navy).withValues(
                alpha: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idCtrl,
                  decoration: InputDecoration(
                    hintText: 'ID Verifikasi (UUID)',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Verifikasi'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
