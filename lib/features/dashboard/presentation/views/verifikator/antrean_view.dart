import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';

// ---------------------------------------------------------------------------
// Provider: fetch pending assets dari backend
// ---------------------------------------------------------------------------

final _pendingAssetsProvider =
    FutureProvider.autoDispose<List<AssetEntity>>((ref) async {
  final ds = VerificationRemoteDataSource();
  final rawList = await ds.fetchPendingAssets();
  return rawList
      .where((a) => a['status'] == 'PENDING_VERIFICATION')
      .map((a) => AssetEntity.fromJson(a as Map<String, dynamic>))
      .toList();
});

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Tab Antrean Verifikasi untuk role Notaris.
class VerifikatorAntreanView extends ConsumerWidget {
  const VerifikatorAntreanView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(authProvider).value?.name ?? 'Notaris';
    final pendingAsync = ref.watch(_pendingAssetsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VerifikatorHeader(userName: userName),
          const SizedBox(height: 24),
          pendingAsync.when(
            loading: () => Row(children: const [
              Expanded(child: WtStatCard(value: '...', label: 'Antrean Baru', color: AppColors.amber)),
              SizedBox(width: 16),
              Expanded(child: WtStatCard(value: '...', label: 'Total Aset', color: AppColors.success)),
            ]),
            error: (_, __) => Row(children: const [
              Expanded(child: WtStatCard(value: '0', label: 'Antrean Baru', color: AppColors.amber)),
              SizedBox(width: 16),
              Expanded(child: WtStatCard(value: '0', label: 'Total Aset', color: AppColors.success)),
            ]),
            data: (assets) => Row(children: [
              Expanded(child: WtStatCard(value: '${assets.length}', label: 'Antrean Baru', color: AppColors.amber)),
              const SizedBox(width: 16),
              Expanded(child: WtStatCard(value: '${assets.length}', label: 'Perlu Verifikasi', color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Membutuhkan Verifikasi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => ref.invalidate(_pendingAssetsProvider),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero),
                child: const Text('Refresh',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          pendingAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => _ErrorBanner(message: e.toString()),
            data: (assets) => assets.isEmpty
                ? const _EmptyQueue()
                : Column(
                    children: assets
                        .map((asset) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _AssetVerificationCard(asset: asset),
                            ))
                        .toList(),
                  ),
          ),
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
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: (isDark ? Colors.white : AppColors.navy)
                    .withOpacity(0.5),
                letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(userName,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1)),
        const SizedBox(height: 4),
        Text('Notaris / Verifikator Legal',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: (isDark ? Colors.white : AppColors.navy)
                    .withOpacity(0.7))),
      ],
    );
  }
}

class _AssetVerificationCard extends ConsumerWidget {
  final AssetEntity asset;
  const _AssetVerificationCard({required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionState = ref.watch(verificationActionProvider(asset.id));

    if (actionState.isDone) {
      return _DoneCard(assetName: asset.assetName, isDark: isDark);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InitialAvatar(
                  initial: asset.assetName.isNotEmpty
                      ? asset.assetName[0].toUpperCase()
                      : 'A'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.assetName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                        '${asset.type.displayName} · ${asset.platform}',
                        style: TextStyle(
                            fontSize: 12,
                            color: (isDark ? Colors.white : AppColors.navy)
                                .withOpacity(0.6))),
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
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.account_circle_outlined,
                    color:
                        (isDark ? Colors.white : AppColors.navy).withOpacity(0.4),
                    size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(asset.accountIdentifier,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),

          // Error
          if (actionState.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(actionState.error!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 12))),
              ]),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Verifikasi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Apakah Anda yakin ingin menolak aset ini?\nPewaris akan mendapat notifikasi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white),
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref
          .read(verificationActionProvider(asset.id).notifier)
          .reject(asset.id);
    }
  }
}

class _DoneCard extends StatelessWidget {
  final String assetName;
  final bool isDark;
  const _DoneCard({required this.assetName, required this.isDark});

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
                const Text('Keputusan Dikirim',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(assetName,
                    style: TextStyle(
                        fontSize: 13,
                        color: (isDark ? Colors.white : AppColors.navy)
                            .withOpacity(0.6))),
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.1),
          shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navy)),
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
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isPrimary ? Colors.white : color,
              ),
            )
          : Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.danger),
        const SizedBox(width: 12),
        Expanded(
            child: Text(message,
                style: const TextStyle(color: AppColors.danger))),
      ]),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 56, color: AppColors.success),
            SizedBox(height: 12),
            Text('Tidak ada antrean.',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('Semua aset telah diverifikasi.',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
