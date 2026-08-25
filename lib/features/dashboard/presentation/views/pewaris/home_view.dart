import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Tab Beranda untuk role Pewaris.
/// Menampilkan greeting, status check-in, stat card aset/ahli waris, dan aktivitas terkini.
class PewarisHomeView extends ConsumerWidget {
  /// Callback untuk navigasi ke tab lain dari dalam view ini.
  final ValueChanged<int> onNavigate;

  const PewarisHomeView({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(authProvider).value?.name ?? 'User';
    final assetsAsync = ref.watch(myAssetsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GreetingHeader(userName: userName),
          const SizedBox(height: 24),
          const _CheckInCard(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.account_balance,
                  iconColor: AppColors.primary,
                  value: assetsAsync.maybeWhen(
                    data: (a) => a.length.toString(),
                    orElse: () => '-',
                  ),
                  label: 'Aset Terdaftar',
                  onTap: () => onNavigate(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.group,
                  iconColor: AppColors.amber,
                  value: '4',
                  label: 'Ahli Waris',
                  onTap: () => onNavigate(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const WtSectionTitle('Aktivitas Terkini'),
          const SizedBox(height: 12),
          const _ActivityList(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets — hanya digunakan oleh PewarisHomeView
// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  final String userName;
  const _GreetingHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELAMAT DATANG',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.5),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pantau status dan aset warisan Anda.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _IconCircle(icon: Icons.health_and_safety, color: AppColors.primary, size: 48),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS AKUN',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.5),
                  ),
                  Text(
                    'Aktif & Aman',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Check-in berikutnya', style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w500)),
              Text('25 hari lagi', style: TextStyle(fontSize: 12, color: AppColors.amber, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.how_to_reg, color: Colors.white),
              label: const Text('Konfirmasi Keaktifan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _QuickStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconCircle(icon: icon, color: iconColor, size: 40),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.0)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList();

  static const _items = [
    (icon: Icons.check_circle, color: AppColors.success, title: 'Check-in Berhasil', date: '23 Jun 2026'),
    (icon: Icons.add_circle, color: AppColors.amber, title: 'Aset Baru: Binance', date: '18 Jun 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < _items.length; i++)
            _ActivityItem(
              icon: _items[i].icon,
              iconColor: _items[i].color,
              title: _items[i].title,
              subtitle: _items[i].date,
              isLast: i == _items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLast;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.05))),
      ),
      child: Row(
        children: [
          _IconCircle(icon: icon, color: iconColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget ikon bulat yang digunakan di seluruh view ini.
class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconCircle({required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.45),
    );
  }
}
