import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';

class ProofReviewCard extends ConsumerWidget {
  final LiquidationProofEntity proof;
  const ProofReviewCard({super.key, required this.proof});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reviewState = ref.watch(reviewLiquidationProofProvider(proof.id));
    final submittedAt = proof.createdAt.toLocal();

    return WtSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            proof.assetName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            'Diajukan Eksekutor ${submittedAt.day}/${submittedAt.month}/${submittedAt.year} · SPTJM disetujui',
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showFileUrl(context, proof),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.warm,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lihat Dokumen e-Statement',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16),
                ],
              ),
            ),
          ),
          if (reviewState.hasError) ...[
            const SizedBox(height: 10),
            Text(
              reviewState.error.toString(),
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: reviewState.isLoading
                      ? null
                      : () => _showRejectDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tolak'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: reviewState.isLoading
                      ? null
                      : () => ref
                            .read(
                              reviewLiquidationProofProvider(proof.id).notifier,
                            )
                            .review(proofId: proof.id, decision: 'APPROVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: reviewState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Setujui'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFileUrl(BuildContext context, LiquidationProofEntity proof) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL Dokumen'),
        content: SelectableText(
          proof.pdfPassword?.isNotEmpty == true
              ? '${proof.pdfFileUrl}\n\nKata sandi: ${proof.pdfPassword}'
              : proof.pdfFileUrl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final notesCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Bukti Pencairan'),
        content: TextField(
          controller: notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Alasan penolakan (wajib diisi)...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, notesCtrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    if (!context.mounted) return;
    ref
        .read(reviewLiquidationProofProvider(proof.id).notifier)
        .review(proofId: proof.id, decision: 'REJECT', notes: reason);
  }
}
