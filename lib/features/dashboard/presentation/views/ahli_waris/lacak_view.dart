import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/ahli_waris_lacak_components.dart';

/// Tab Lacak Verifikasi — progres verifikasi berjenjang per Pewaris.
///
/// Sumber data: GET /inheritance/progress/me (status akta kematian & rekap
/// saksi) + status aset teralokasi (masa tunda & pelepasan kunci). Dulu
/// tahap 2–4 hanya tebakan dari status aset, sehingga Pewaris yang masih
/// hidup dan yang sudah wafat tampil nyaris sama.
class AhliWarisLacakView extends ConsumerWidget {
  const AhliWarisLacakView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(myInheritanceProgressProvider);
    final assets = ref.watch(allocatedAssetsProvider).valueOrNull ?? const [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WtScreenHeader(
            label: 'Status',
            title: 'Verifikasi Legal',
            trailing: TextButton(
              onPressed: () {
                ref.invalidate(myInheritanceProgressProvider);
                ref.invalidate(allocatedAssetsProvider);
              },
              child: const Text('Refresh'),
            ),
          ),
          const SizedBox(height: 24),
          progressAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => WtErrorBanner(message: e.toString()),
            data: (items) {
              final entries = items.whereType<Map<String, dynamic>>().toList();
              if (entries.isEmpty) {
                return const WtEmptyState(
                  message: 'Belum terhubung dengan Pewaris mana pun.',
                  icon: Icons.link_off,
                );
              }
              return Column(
                children: [
                  for (final progress in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ProgressCard(
                        progress: progress,
                        assets: assets
                            .where(
                              (a) => a.pewarisId == progress['pewarisId'],
                            )
                            .toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Map<String, dynamic> progress;
  final List<AssetEntity> assets;

  const _ProgressCard({required this.progress, required this.assets});

  static const _releasedStatuses = {
    AssetStatus.unlocked,
    AssetStatus.liquidating,
    AssetStatus.distributed,
    AssetStatus.disputedLiquidation,
    AssetStatus.closed,
  };

  String _formatDate(Object? raw) {
    final dt = DateTime.tryParse(raw?.toString() ?? '')?.toLocal();
    return dt == null ? '-' : '${dt.day}/${dt.month}/${dt.year}';
  }

  List<TimelineStep> _steps() {
    final pewarisName = progress['pewarisName']?.toString() ?? 'Pewaris';
    final certStatus = progress['deathCertificateStatus']?.toString();
    final total = (progress['witnessTotal'] as num?)?.toInt() ?? 0;
    final approved = (progress['witnessApproved'] as num?)?.toInt() ?? 0;
    final disputed = (progress['witnessDisputed'] as num?)?.toInt() ?? 0;
    final required = (progress['witnessRequired'] as num?)?.toInt() ?? 3;

    final released = assets.any((a) => _releasedStatuses.contains(a.status));
    final inCooldown = assets.any(
      (a) => a.status == AssetStatus.pendingCooldown,
    );
    final certVerified = certStatus == 'VERIFIED';
    // Backend baru memulai masa tunda bila SEMUA saksi menyetujui DAN
    // jumlahnya >= minimum — kondisi yang sama dipakai di sini.
    final witnessesDone =
        released ||
        inCooldown ||
        (total >= required && approved == total && total > 0);

    final certStep = switch (certStatus) {
      'VERIFIED' => TimelineStep(
        title: 'Akta Kematian',
        desc:
            'Diverifikasi Notaris pada ${_formatDate(progress['deathCertificateVerifiedAt'])}.',
        isDone: true,
      ),
      'PENDING_VERIFICATION' => TimelineStep(
        title: 'Akta Kematian',
        desc:
            'Diajukan ${_formatDate(progress['deathCertificateSubmittedAt'])} — menunggu verifikasi Notaris.',
        isCurrent: true,
      ),
      _ => const TimelineStep(
        title: 'Akta Kematian',
        desc:
            'Belum ada akta yang diajukan. Ajukan lewat tab Lapor bila Pewaris telah wafat.',
        isCurrent: true,
      ),
    };

    final witnessDesc = StringBuffer(
      '$approved dari minimal $required saksi menyetujui',
    );
    if (total < required) {
      witnessDesc.write(' (Pewaris baru mendaftarkan $total saksi)');
    }
    if (disputed > 0) {
      witnessDesc.write(' · $disputed menyanggah — aset dibekukan');
    }
    witnessDesc.write('.');

    return [
      TimelineStep(
        title: 'Pewaris Terdaftar',
        desc: 'Sistem memonitor status Proof-of-Life $pewarisName.',
        isDone: true,
      ),
      certStep,
      TimelineStep(
        title: 'Persetujuan Saksi',
        desc: witnessDesc.toString(),
        isDone: witnessesDone,
        isCurrent: certVerified && !witnessesDone,
      ),
      TimelineStep(
        title: 'Masa Tunda 14 Hari',
        desc: 'Jeda untuk sanggahan sebelum brankas terbuka otomatis.',
        isDone: released,
        isCurrent: inCooldown && !released,
      ),
      TimelineStep(
        title: 'Pelepasan Kunci Brankas',
        desc:
            'Bagian kunci SYSTEM diserahkan ke Eksekutor untuk digabung dengan bagiannya (Shamir 2-dari-3).',
        isDone: released,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = _steps();

    return WtSurfaceCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progress['pewarisName']?.toString() ?? 'Pewaris',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Positioned(
                left: 9,
                top: 12,
                bottom: 12,
                child: Container(
                  width: 2,
                  color: (isDark ? Colors.white : AppColors.navy).withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              Column(
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 24),
                    LegalTimelineItem(step: steps[i]),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
