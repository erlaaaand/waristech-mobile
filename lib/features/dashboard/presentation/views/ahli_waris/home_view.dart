import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Tab Beranda untuk role Ahli Waris.
class AhliWarisHomeView extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const AhliWarisHomeView({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final userName = user?.name ?? 'Ahli Waris';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AhliWarisHeader(userName: userName),
          const SizedBox(height: 24),
          const _LockedAccessBanner(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.upload_file, label: 'Lapor\nKematian', sub: 'Unggah Akta', isPrimary: true, onTap: () => onNavigate(1))),
              const SizedBox(width: 16),
              Expanded(child: _QuickAction(icon: Icons.policy, label: 'Lacak\nVerifikasi', sub: 'Cek Status', isPrimary: false, onTap: () => onNavigate(2))),
            ],
          ),
          const SizedBox(height: 24),
          const WtSectionTitle('Informasi Pewaris'),
          const SizedBox(height: 12),
          const _PewarisInfoCard(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AhliWarisHeader extends StatelessWidget {
  final String userName;
  const _AhliWarisHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELAMAT DATANG', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.5), letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.1)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Text('Eksekutor Utama', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.0)),
            ),
            const SizedBox(width: 8),
            Text('Ahli Waris Terdaftar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.7))),
          ],
        ),
      ],
    );
  }
}

class _LockedAccessBanner extends StatelessWidget {
  const _LockedAccessBanner();

  @override
  Widget build(BuildContext context) {
    return WtInfoCard(
      icon: Icons.lock_clock,
      iconColor: AppColors.amber,
      title: 'Akses Terkunci',
      description: 'Brankas warisan saat ini dalam masa tunggu. Anda memerlukan verifikasi hukum (Akta Kematian) untuk membuka kunci enkripsi.',
      padding: const EdgeInsets.all(24),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.sub, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isPrimary ? AppColors.primary : (isDark ? AppColors.darkSurface : AppColors.surface);
    final fgColor = isPrimary ? Colors.white : (isDark ? Colors.white : AppColors.navy);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: (isPrimary ? Colors.white : fgColor).withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: isPrimary ? Colors.white : fgColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fgColor, height: 1.1)),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 11, color: fgColor.withOpacity(0.6), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _PewarisInfoCard extends StatelessWidget {
  const _PewarisInfoCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.05), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('B', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.navy)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bapak Budi Santoso', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Ayah Kandung', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6))),
              ],
            ),
          ),
          const WtStatusBadge(label: 'Aktif', color: AppColors.success),
        ],
      ),
    );
  }
}
