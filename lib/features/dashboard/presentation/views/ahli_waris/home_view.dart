import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/ahli_waris_home_components.dart';

class AhliWarisHomeView extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const AhliWarisHomeView({super.key, required this.onNavigate});

  static const int _profilTabIndex = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final userName = user?.name ?? 'Ahli Waris';
    final allocatedAssetsAsync = ref.watch(allocatedAssetsProvider);
    final isExecutor = allocatedAssetsAsync.maybeWhen(
      data: (assets) => assets.any(
        (a) => a.allocations.any(
          (alloc) => alloc.ahliWarisId == user?.id && alloc.isExecutor,
        ),
      ),
      orElse: () => false,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHomeHeader(
            userName: userName,
            onOpenProfile: () => onNavigate(_profilTabIndex),
            subtitle: Row(
              children: [
                if (isExecutor) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Eksekutor',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  'Ahli Waris Terdaftar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.navy.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AccessStatusBanner(assetsAsync: allocatedAssetsAsync),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: QuickAction(
                  icon: Icons.upload_file,
                  label: 'Lapor\nKematian',
                  sub: 'Unggah Akta',
                  isPrimary: true,
                  onTap: () => onNavigate(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: QuickAction(
                  icon: Icons.policy,
                  label: 'Lacak\nVerifikasi',
                  sub: 'Cek Status',
                  isPrimary: false,
                  onTap: () => onNavigate(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const WtSectionTitle('Informasi Pewaris'),
          const SizedBox(height: 12),
          const PewarisInfoCard(),
        ],
      ),
    );
  }
}
