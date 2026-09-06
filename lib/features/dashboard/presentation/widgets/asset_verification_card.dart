import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';

class AssetVerificationCard extends ConsumerWidget {
  final AssetEntity asset;
  const AssetVerificationCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionState = ref.watch(verificationActionProvider(asset.id));

    if (actionState.isDone) {
      return DoneCard(assetName: asset.assetName, isDark: isDark);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : AppColors.navy).withValues(
            alpha: 0.05,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialAvatar(
                initial: asset.assetName.isNotEmpty
                    ? asset.assetName[0].toUpperCase()
                    : 'A',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assetName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${asset.type.displayName} · ${asset.platform}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : AppColors.navy.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const WtStatusBadge(label: 'Menunggu', color: AppColors.amber),
            ],
          ),
          const SizedBox(height: 12),

          // Account identifier info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.warm,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: (isDark ? Colors.white : AppColors.navy).withValues(
                    alpha: 0.4,
                  ),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    asset.accountIdentifier,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error
          if (actionState.error != null) ...[
            const SizedBox(height: 12),
            WtErrorBanner(
              message: actionState.error!,
              padding: const EdgeInsets.all(12),
              borderRadius: 12,
              iconSize: 16,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Tolak',
                  color: AppColors.danger,
                  isLoading: actionState.isLoading,
                  onPressed: () => _showRejectDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  label: 'Verifikasi',
                  color: AppColors.primary,
                  isPrimary: true,
                  isLoading: actionState.isLoading,
                  onPressed: () => ref
                      .read(verificationActionProvider(asset.id).notifier)
                      .verify(asset.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Verifikasi Aset'),
        content: TextField(
          controller: reasonCtrl,
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
            onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()),
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
        .read(verificationActionProvider(asset.id).notifier)
        .reject(asset.id, reason);
  }
}

class DoneCard extends StatelessWidget {
  final String assetName;
  final bool isDark;
  const DoneCard({super.key, required this.assetName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keputusan Dikirim',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  assetName,
                  style: TextStyle(
                    fontSize: 13,
                    color: (isDark ? Colors.white : AppColors.navy).withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InitialAvatar extends StatelessWidget {
  final String initial;
  const InitialAvatar({super.key, required this.initial});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : AppColors.navy).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.navy,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
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
        backgroundColor: isPrimary ? color : color.withValues(alpha: 0.1),
        foregroundColor: isPrimary ? Colors.white : color,
        elevation: isPrimary ? 1 : 0,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isPrimary ? Colors.white : color,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
    );
  }
}
