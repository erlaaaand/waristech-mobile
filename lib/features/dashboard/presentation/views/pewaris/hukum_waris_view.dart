import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

/// Tab Hukum Waris — kalkulasi pembagian warisan (Faraidh/Perdata/Adat).
class PewarisHukumWarisView extends StatefulWidget {
  const PewarisHukumWarisView({super.key});

  @override
  State<PewarisHukumWarisView> createState() => _PewarisHukumWarisViewState();
}

class _PewarisHukumWarisViewState extends State<PewarisHukumWarisView> {
  int _selectedScheme = 2; // 0=Perdata, 1=Adat, 2=Faraidh

  static const _schemes = ['Perdata', 'Adat', 'Faraidh'];

  static const _heirs = [
    _HeirData(name: 'Siti Rahma', relation: 'Istri · Kontak Darurat', percent: '12.5%', fraction: 0.125, initial: 'S'),
    _HeirData(name: 'Budi Santoso', relation: 'Anak Laki-laki', percent: '58.3%', fraction: 0.583, initial: 'B'),
    _HeirData(name: 'Ani Santoso', relation: 'Anak Perempuan', percent: '29.2%', fraction: 0.292, initial: 'A'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtSectionTitle('Kalkulasi'),
          const SizedBox(height: 4),
          const Text('Skema Waris', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          _SchemeSelector(
            schemes: _schemes,
            selectedIndex: _selectedScheme,
            onChanged: (i) => setState(() => _selectedScheme = i),
          ),
          const SizedBox(height: 20),
          _CalculationCard(
            schemeName: _schemes[_selectedScheme],
            heirs: _heirs,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const WtSectionTitle('Ahli Waris'),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle, size: 16),
                label: const Text('Tambah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._heirs.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HeirCard(data: h),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model (immutable, lokal di file ini)
// ---------------------------------------------------------------------------

class _HeirData {
  final String name;
  final String relation;
  final String percent;
  final double fraction;
  final String initial;

  const _HeirData({
    required this.name,
    required this.relation,
    required this.percent,
    required this.fraction,
    required this.initial,
  });
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SchemeSelector extends StatelessWidget {
  final List<String> schemes;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SchemeSelector({required this.schemes, required this.selectedIndex, required this.onChanged});

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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      )
                    : null,
                child: Text(
                  schemes[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? (isDark ? AppColors.navy : Colors.white) : (isDark ? Colors.white54 : AppColors.navy.withOpacity(0.7)),
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

class _CalculationCard extends StatelessWidget {
  final String schemeName;
  final List<_HeirData> heirs;

  const _CalculationCard({required this.schemeName, required this.heirs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL ESTIMASI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.4), letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  const Text('Rp 2,5 Miliar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              WtStatusBadge(label: '$schemeName Islam', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),
          ...heirs.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _HeirProgressBar(data: h),
              )),
        ],
      ),
    );
  }
}

class _HeirProgressBar extends StatelessWidget {
  final _HeirData data;
  const _HeirProgressBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(data.percent, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: data.fraction,
            backgroundColor: (isDark ? Colors.white : AppColors.navy).withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

class _HeirCard extends StatelessWidget {
  final _HeirData data;
  const _HeirCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(data.initial, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(data.relation, style: TextStyle(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Text(data.percent, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }
}
