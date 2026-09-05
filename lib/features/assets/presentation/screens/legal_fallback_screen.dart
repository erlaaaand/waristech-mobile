import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_guidance_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/assets/presentation/screens/asset_guidance_screen.dart';

/// Ajukan jalur pemulihan hukum konvensional — POST /assets/:id/legal-fallback.
/// JUJUR: endpoint ini TIDAK memulihkan kunci digital. Bila bagian kunci yang
/// tersisa di server kurang dari 2, kredensial secara matematis TIDAK DAPAT
/// dipulihkan siapa pun (konsekuensi Shamir 2-dari-3) — hanya panduan jalur
/// resmi & pencatatan audit trail sebagai bukti pendukung proses hukum.
class LegalFallbackScreen extends ConsumerStatefulWidget {
  final String assetId;
  final String assetName;
  const LegalFallbackScreen({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  ConsumerState<LegalFallbackScreen> createState() =>
      _LegalFallbackScreenState();
}

class _LegalFallbackScreenState extends ConsumerState<LegalFallbackScreen> {
  final _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Alasan wajib diisi.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(assetRepositoryProvider)
          .requestLegalFallback(assetId: widget.assetId, reason: reason);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _result = result;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Jalur Hukum Konvensional')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: result != null
              ? _LegalFallbackResult(
                  assetName: widget.assetName,
                  result: result,
                )
              : _LegalFallbackForm(
                  assetName: widget.assetName,
                  reasonController: _reasonCtrl,
                  error: _error,
                  isSubmitting: _isSubmitting,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

/// Formulir permohonan jalur hukum konvensional.
class _LegalFallbackForm extends StatelessWidget {
  final String assetName;
  final TextEditingController reasonController;
  final String? error;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _LegalFallbackForm({
    required this.assetName,
    required this.reasonController,
    required this.error,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          assetName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Gunakan HANYA bila kunci digital tidak dapat direkonstruksi (mis. '
            'perangkat Eksekutor hilang tanpa cadangan). Ini TIDAK memulihkan '
            'kunci — sistem hanya memberi panduan jalur resmi dan mencatat '
            'permohonan ini sebagai bukti pendukung proses hukum.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.danger,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Alasan',
            hintText: 'Contoh: Perangkat Eksekutor hilang dan bagian kunci tidak tercadangkan.',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: const TextStyle(color: AppColors.danger, fontSize: 13),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text('Ajukan Permohonan'),
          ),
        ),
      ],
    );
  }
}

/// Tampilan hasil setelah permohonan terkirim.
class _LegalFallbackResult extends StatelessWidget {
  final String assetName;
  final Map<String, dynamic> result;

  const _LegalFallbackResult({required this.assetName, required this.result});

  @override
  Widget build(BuildContext context) {
    final keyRecoveryPossible = result['keyRecoveryPossible'] as bool? ?? false;
    final explanation = result['explanation']?.toString() ?? '';
    final guidanceJson = result['guidance'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (keyRecoveryPossible ? AppColors.amber : AppColors.danger)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                keyRecoveryPossible ? Icons.info_outline : Icons.error_outline,
                color: keyRecoveryPossible ? AppColors.amber : AppColors.danger,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(explanation, style: const TextStyle(height: 1.4)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (guidanceJson != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AssetGuidanceScreen(
                    assetName: assetName,
                    preloaded: AssetGuidanceEntity.fromJson(guidanceJson),
                  ),
                ),
              ),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Lihat Panduan Jalur Resmi'),
            ),
          ),
      ],
    );
  }
}
