import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

/// Tab Riwayat Keputusan untuk role Verifikator/Notaris.
class VerifikatorRiwayatView extends StatelessWidget {
  const VerifikatorRiwayatView({super.key});

  static const _history = [
    _HistoryEntry(pewaris: 'Alm. Budi Haryanto', pelapor: 'Dedi (Anak)', date: '14 Agu 2026', isApproved: true),
    _HistoryEntry(pewaris: 'Alm. Tono Sugiarto', pelapor: 'Budi (Adik)', date: '12 Agu 2026', isApproved: false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtSectionTitle('Riwayat'),
          const SizedBox(height: 4),
          const Text('Keputusan Legal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama pewaris atau pelapor...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          ..._history.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(entry: e),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _HistoryEntry {
  final String pewaris;
  final String pelapor;
  final String date;
  final bool isApproved;

  const _HistoryEntry({
    required this.pewaris,
    required this.pelapor,
    required this.date,
    required this.isApproved,
  });
}

class _HistoryCard extends StatelessWidget {
  final _HistoryEntry entry;
  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = entry.isApproved ? AppColors.success : AppColors.danger;
    final statusLabel = entry.isApproved ? 'Disetujui' : 'Ditolak';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.pewaris, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              WtStatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text('Pelapor: ${entry.pelapor}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6))),
          const SizedBox(height: 8),
          Text('Diverifikasi pada: ${entry.date}', style: TextStyle(fontSize: 11, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.4))),
        ],
      ),
    );
  }
}
