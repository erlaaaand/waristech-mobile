import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

/// Tab Hukum Waris — kalkulasi pembagian warisan + daftar ahli waris nyata.
class PewarisHukumWarisView extends ConsumerStatefulWidget {
  const PewarisHukumWarisView({super.key});

  @override
  ConsumerState<PewarisHukumWarisView> createState() =>
      _PewarisHukumWarisViewState();
}

class _PewarisHukumWarisViewState
    extends ConsumerState<PewarisHukumWarisView> {
  int _selectedScheme = 2;
  static const _schemes = ['Perdata', 'Adat', 'Faraidh'];

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(familyMembersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtSectionTitle('Kalkulasi'),
          const SizedBox(height: 4),
          const Text('Skema Waris',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 24),
          _SchemeSelector(
            schemes: _schemes,
            selectedIndex: _selectedScheme,
            onChanged: (i) => setState(() => _selectedScheme = i),
          ),
          const SizedBox(height: 20),
          familyAsync.when(
            loading: () => const _CardSkeleton(),
            error: (_, __) => _SummaryCard(
                schemeName: _schemes[_selectedScheme], memberCount: 0),
            data: (members) => _SummaryCard(
                schemeName: _schemes[_selectedScheme],
                memberCount: members.length),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const WtSectionTitle('Ahli Waris'),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle, size: 16),
                label: const Text('Undang',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 12),
          familyAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => _ErrorBanner(message: e.toString()),
            data: (members) => members.isEmpty
                ? const _EmptyHeirs()
                : Column(
                    children: members
                        .map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HeirCard(member: m),
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

class _SchemeSelector extends StatelessWidget {
  final List<String> schemes;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SchemeSelector({
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
        color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.05),
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
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4)
                        ],
                      )
                    : null,
                child: Text(
                  schemes[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive
                        ? (isDark ? AppColors.navy : Colors.white)
                        : (isDark
                            ? Colors.white54
                            : AppColors.navy.withOpacity(0.7)),
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

class _SummaryCard extends StatelessWidget {
  final String schemeName;
  final int memberCount;
  const _SummaryCard(
      {required this.schemeName, required this.memberCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL AHLI WARIS',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (isDark ? Colors.white : AppColors.navy)
                          .withOpacity(0.4),
                      letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('$memberCount orang',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          WtStatusBadge(
              label: 'Skema $schemeName', color: AppColors.primary),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

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

class _HeirCard extends StatelessWidget {
  final dynamic member;
  const _HeirCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = member['ahliWarisName']?.toString() ??
        member['fullName']?.toString() ??
        'Ahli Waris';
    final relation =
        member['relationshipType']?.toString() ?? 'Belum ditentukan';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isConfirmed = member['isConfirmedByPewaris'] == true ||
        member['status'] == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(relation,
                    style: TextStyle(
                        color: (isDark ? Colors.white : AppColors.navy)
                            .withOpacity(0.6),
                        fontSize: 12)),
              ],
            ),
          ),
          WtStatusBadge(
            label: isConfirmed ? 'Aktif' : 'Menunggu',
            color: isConfirmed ? AppColors.success : AppColors.amber,
          ),
        ],
      ),
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

class _EmptyHeirs extends StatelessWidget {
  const _EmptyHeirs();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada ahli waris terdaftar.',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            Text('Bagikan kode undangan untuk menambahkan ahli waris.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
