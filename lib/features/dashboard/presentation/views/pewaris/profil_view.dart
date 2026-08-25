import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Tab Profil & Audit Trail untuk role Pewaris.
class PewarisProfilView extends ConsumerWidget {
  const PewarisProfilView({super.key});

  static const _logs = [
    _LogEntry(date: '26 Agu 2026', title: 'Kunci Akses Dirilis', desc: 'Kunci enkripsi dikirim ke ahli waris terdaftar.', isSuccess: true),
    _LogEntry(date: '12 Agu 2026', title: 'Verifikasi Notaris Selesai', desc: 'Akta Kematian diunggah dan terverifikasi.', isSuccess: true),
    _LogEntry(date: '15 Jul 2026', title: 'Notifikasi Darurat Dikirim', desc: 'Kontak darurat tingkat 2 diinisiasi.', isSuccess: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtSectionTitle('Akun'),
          const SizedBox(height: 4),
          const Text('Profil & Log', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          _ProfileCard(
            name: user?.name ?? 'Ahmad Santoso',
            email: user?.email ?? 'ahmad@email.com',
          ),
          const SizedBox(height: 24),
          const WtSectionTitle('Riwayat Eksekusi'),
          const SizedBox(height: 12),
          ..._logs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LogCard(entry: log),
              )),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: AppColors.danger),
            label: const Text('Keluar Akun', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _LogEntry {
  final String date;
  final String title;
  final String desc;
  final bool isSuccess;

  const _LogEntry({required this.date, required this.title, required this.desc, required this.isSuccess});
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  const _ProfileCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 2),
              Text(email, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final _LogEntry entry;
  const _LogCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = entry.isSuccess ? AppColors.success : AppColors.amber;

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
              Text(entry.date,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.4), letterSpacing: 1.5)),
              WtStatusBadge(label: entry.isSuccess ? 'Selesai' : 'Peringatan', color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(entry.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(entry.desc,
              style: TextStyle(fontSize: 12, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), height: 1.4)),
        ],
      ),
    );
  }
}
