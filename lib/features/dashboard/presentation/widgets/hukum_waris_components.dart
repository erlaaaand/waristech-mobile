import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

class SchemeSelector extends StatelessWidget {
  final List<String> schemes;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SchemeSelector({
    super.key,
    required this.schemes,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : AppColors.navy).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(schemes.length, (i) {
          final isActive = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: isActive
                    ? BoxDecoration(
                        color: isDark ? Colors.white : AppColors.navy,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      )
                    : null,
                child: Text(
                  schemes[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive
                        ? (isDark ? AppColors.navy : Colors.white)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.navy.withValues(alpha: 0.7)),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String schemeName;
  final int memberCount;
  const SummaryCard({
    super.key,
    required this.schemeName,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.gray50,
        border: Border.all(
          color: isDark ? AppColors.gray800 : AppColors.gray200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL AHLI WARIS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray400,
                  letterSpacing: 0.66,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$memberCount orang',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          WtStatusBadge(label: 'Skema $schemeName', color: AppColors.primary),
        ],
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.warm,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class HeirCard extends ConsumerWidget {
  final dynamic member;
  const HeirCard({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final relation =
        (member['relationshipDescription']?.toString().isNotEmpty ?? false)
        ? member['relationshipDescription'].toString()
        : 'Hubungan belum diisi';
    final name = relation;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final status = member['status']?.toString() ?? '';
    final isConfirmed = status == 'VERIFIED';
    final canConfirm = status == 'PENDING_CONFIRMATION';
    final confirmState = ref.watch(confirmMemberProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.gray50,
        border: Border.all(
          color: isDark ? AppColors.gray800 : AppColors.gray200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border.all(
                color: isDark ? AppColors.gray700 : AppColors.gray200,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppColors.gray700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  relation,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (canConfirm)
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: confirmState.isLoading
                    ? null
                    : () => ref
                          .read(confirmMemberProvider.notifier)
                          .confirm(member['id'].toString()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: confirmState.isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Konfirmasi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )
          else
            WtStatusBadge(
              label: isConfirmed ? 'Aktif' : 'Menunggu',
              color: isConfirmed ? AppColors.success : AppColors.amber,
            ),
        ],
      ),
    );
  }
}
