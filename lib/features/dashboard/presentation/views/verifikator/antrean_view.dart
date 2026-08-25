import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';

// ---------------------------------------------------------------------------
// Data model lokal (akan diganti dengan model dari API)
// ---------------------------------------------------------------------------

class _VerifRequest {
  final String id;
  final String initial;
  final String pewaris;
  final String pelapor;
  final String document;
  final String uploadedAt;

  const _VerifRequest({
    required this.id,
    required this.initial,
    required this.pewaris,
    required this.pelapor,
    required this.document,
    required this.uploadedAt,
  });
}

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Tab Antrean Verifikasi untuk role Verifikator/Notaris.
class VerifikatorAntreanView extends ConsumerWidget {
  const VerifikatorAntreanView({super.key});

  static const _requests = [
    _VerifRequest(
      id: 'verif-001',
      initial: 'B',
      pewaris: 'Alm. Bapak Budi Santoso',
      pelapor: 'Andi Santoso (Anak)',
      document: 'Akta_Kematian_Budi.pdf',
      uploadedAt: '2 jam yang lalu',
    ),
    _VerifRequest(
      id: 'verif-002',
      initial: 'S',
      pewaris: 'Alm. Siti Rahma',
      pelapor: 'Ahmad (Suami)',
      document: 'Akta_Siti.pdf',
      uploadedAt: '5 jam yang lalu',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(authProvider).value?.name ?? 'Notaris';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VerifikatorHeader(userName: userName),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: WtStatCard(value: '2', label: 'Antrean Baru', color: AppColors.amber)),
              SizedBox(width: 16),
              Expanded(child: WtStatCard(value: '14', label: 'Disetujui Bulan Ini', color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Membutuhkan Verifikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
                child: const Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._requests.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _VerificationCard(request: req),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _VerifikatorHeader extends StatelessWidget {
  final String userName;
  const _VerifikatorHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELAMAT DATANG',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.5), letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.1)),
        const SizedBox(height: 4),
        Text('Verifikator Legal',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.7))),
      ],
    );
  }
}

class _VerificationCard extends ConsumerWidget {
  final _VerifRequest request;
  const _VerificationCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionState = ref.watch(verificationActionProvider(request.id));

    // Jika aksi sudah selesai, tampilkan konfirmasi
    if (actionState.isDone) {
      return _DoneCard(pewaris: request.pewaris, isDark: isDark);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InitialAvatar(initial: request.initial),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.pewaris, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Pelapor: ${request.pelapor}',
                        style: TextStyle(fontSize: 12, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6))),
                  ],
                ),
              ),
              const WtStatusBadge(label: 'Menunggu', color: AppColors.amber),
            ],
          ),
          const SizedBox(height: 16),

          // Document preview
          _DocumentPreview(document: request.document, uploadedAt: request.uploadedAt),

          // Error jika ada
          if (actionState.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(actionState.error!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
              ]),
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Tolak',
                  color: AppColors.danger,
                  isLoading: actionState.isLoading,
                  onPressed: () => _showRejectDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Setujui & Rilis',
                  color: AppColors.primary,
                  isPrimary: true,
                  isLoading: actionState.isLoading,
                  onPressed: () => ref
                      .read(verificationActionProvider(request.id).notifier)
                      .approve(request.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Verifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Berikan alasan penolakan:', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Dokumen tidak terbaca / tidak valid',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(verificationActionProvider(request.id).notifier).reject(
            request.id,
            controller.text.trim().isEmpty ? 'Tidak ada alasan' : controller.text.trim(),
          );
    }
    controller.dispose();
  }
}

class _DoneCard extends StatelessWidget {
  final String pewaris;
  final bool isDark;

  const _DoneCard({required this.pewaris, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keputusan Dikirim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(pewaris, style: TextStyle(fontSize: 13, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;
  const _InitialAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.1), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.navy)),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  final String document;
  final String uploadedAt;

  const _DocumentPreview({required this.document, required this.uploadedAt});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.warm, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.description, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text('Diunggah $uploadedAt', style: TextStyle(fontSize: 11, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.5))),
              ],
            ),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.visibility, color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    this.isPrimary = false,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : color.withOpacity(0.1),
        foregroundColor: isPrimary ? Colors.white : color,
        elevation: isPrimary ? 1 : 0,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: isLoading
          ? SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isPrimary ? Colors.white : color,
              ),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
