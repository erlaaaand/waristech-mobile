import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/verification/presentation/providers/verification_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/asset_verification_card.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/death_certificate_verification_card.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/family_member_review_card.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/verifikator_header.dart';

// ---------------------------------------------------------------------------
// Provider: fetch pending assets dari backend
// ---------------------------------------------------------------------------

/// Publik (bukan file-private) supaya `verifikator_dashboard_screen.dart`
/// bisa ikut memantau jumlah antrean untuk badge nav — lihat A.3.
final pendingAssetsNotarisProvider = FutureProvider.autoDispose<
  List<AssetEntity>
>((
  ref,
) async {
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
    final pendingAsync = ref.watch(pendingAssetsNotarisProvider);
    final familyAsync = ref.watch(pendingFamilyMembersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerifikatorHeader(userName: userName),
          const SizedBox(height: 24),
          const Text(
            'Akta Kematian',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _PendingDeathCertificatesSection(),
          const SizedBox(height: 24),
          const Text(
            'Relasi Keluarga Non-Nasab',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _PendingFamilyMembersSection(),
          const SizedBox(height: 24),
          // Dua kartu ini SENGAJA punya label/warna yang TETAP di ketiga
          // state (loading/error/data) — sebelumnya label & warna kartu
          // kedua berubah-ubah tergantung state, dan kedua kartu selalu
          // menampilkan angka yang SAMA (assets.length dobel) walau tab ini
          // sekarang juga punya antrean relasi Non-Nasab terpisah di atas.
          Row(
            children: [
              Expanded(
                child: WtStatCard(
                  value: pendingAsync.isLoading
                      ? '...'
                      : '${pendingAsync.valueOrNull?.length ?? 0}',
                  label: 'Aset Pending',
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: WtStatCard(
                  value: familyAsync.isLoading
                      ? '...'
                      : '${familyAsync.valueOrNull?.length ?? 0}',
                  label: 'Relasi Pending',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Membutuhkan Verifikasi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => ref.invalidate(pendingAssetsNotarisProvider),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          pendingAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => WtErrorBanner(message: e.toString()),
            data: (assets) => assets.isEmpty
                ? const WtEmptyState(
                    message: 'Tidak ada antrean.',
                    subtitle: 'Semua aset telah diverifikasi.',
                    icon: Icons.task_alt,
                    iconColor: AppColors.success,
                    iconSize: 56,
                    messageStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : Column(
                    children: assets
                        .map(
                          (asset) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AssetVerificationCard(asset: asset),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Antrean dokumen akta kematian yang menunggu verifikasi Notaris —
/// GET /inheritance/death-certificate/notaris/pending.
class _PendingDeathCertificatesSection extends ConsumerWidget {
  const _PendingDeathCertificatesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDeathCertificatesProvider);

    return pendingAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => WtErrorBanner(message: e.toString()),
      data: (items) => items.isEmpty
          ? const WtEmptyState(
              message: 'Tidak ada akta kematian yang menunggu.',
              icon: Icons.task_alt,
              iconColor: AppColors.success,
              iconSize: 40,
            )
          : Column(
              children: items
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DeathCertificateReviewCard(item: item),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

/// Antrean relasi keluarga Non-Nasab yang menunggu verifikasi Notaris —
/// GET /inheritance/family-members/notaris/pending.
class _PendingFamilyMembersSection extends ConsumerWidget {
  const _PendingFamilyMembersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingFamilyMembersProvider);

    return pendingAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => WtErrorBanner(message: e.toString()),
      data: (members) => members.isEmpty
          ? const WtEmptyState(
              message: 'Tidak ada relasi Non-Nasab yang menunggu.',
              icon: Icons.task_alt,
              iconColor: AppColors.success,
              iconSize: 40,
            )
          : Column(
              children: members
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (member) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FamilyMemberReviewCard(member: member),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
