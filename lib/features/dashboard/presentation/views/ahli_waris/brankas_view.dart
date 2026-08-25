import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

/// Tab Brankas — menampilkan aset warisan yang terkunci/terbuka.
class AhliWarisBrankasView extends StatefulWidget {
  const AhliWarisBrankasView({super.key});

  @override
  State<AhliWarisBrankasView> createState() => _AhliWarisBrankasViewState();
}

class _AhliWarisBrankasViewState extends State<AhliWarisBrankasView> {
  bool _isUnlocked = false;
  bool _isDecrypting = false;

  void _startUnlock() {
    setState(() => _isDecrypting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _isDecrypting = false; _isUnlocked = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrankasHeader(isUnlocked: _isUnlocked, onDemoUnlock: _startUnlock),
          const SizedBox(height: 24),
          _BrankasContainer(isUnlocked: _isUnlocked, isDecrypting: _isDecrypting),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _BrankasHeader extends StatelessWidget {
  final bool isUnlocked;
  final VoidCallback onDemoUnlock;

  const _BrankasHeader({required this.isUnlocked, required this.onDemoUnlock});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WtSectionTitle('Inventaris'),
            const SizedBox(height: 4),
            const Text('Brankas Aset', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ],
        ),
        if (!isUnlocked)
          OutlinedButton(
            onPressed: onDemoUnlock,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.amber,
              side: BorderSide(color: AppColors.amber.withOpacity(0.2)),
              backgroundColor: AppColors.amber.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Demo Buka Kunci', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

class _BrankasContainer extends StatelessWidget {
  final bool isUnlocked;
  final bool isDecrypting;

  const _BrankasContainer({required this.isUnlocked, required this.isDecrypting});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Content layer (blurred skeleton or unlocked assets)
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isUnlocked ? const _UnlockedAssets() : const _SkeletonAssets(),
              ),
            ),

            // Locked overlay
            if (!isUnlocked && !isDecrypting) const _LockedOverlay(),

            // Decrypting animation
            if (isDecrypting) const _DecryptingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _SkeletonAssets extends StatelessWidget {
  const _SkeletonAssets();

  @override
  Widget build(BuildContext context) {
    final color = (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.navy).withOpacity(0.05);
    final color2 = (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.navy).withOpacity(0.1);

    return Column(
      children: List.generate(2, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: color2, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 12, decoration: BoxDecoration(color: color2, borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  Container(width: 60, height: 8, decoration: BoxDecoration(color: color2, borderRadius: BorderRadius.circular(4))),
                ],
              )),
            ],
          ),
        ),
      )),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: Container(
        color: (isDark ? AppColors.darkSurface : AppColors.surface).withOpacity(0.85),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.lock, size: 28, color: isDark ? Colors.white : AppColors.navy),
            ),
            const SizedBox(height: 16),
            const Text('Brankas Terkunci Enkripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Selesaikan verifikasi legal untuk membuka akses aset warisan Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecryptingOverlay extends StatelessWidget {
  const _DecryptingOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: Container(
        color: (isDark ? AppColors.darkBackground : AppColors.navy).withOpacity(0.92),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SpinnerWithKey(),
            SizedBox(height: 24),
            Text('Merekonstruksi Kunci...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            SizedBox(height: 8),
            Text("Shamir's Secret Sharing Algoritma", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _SpinnerWithKey extends StatelessWidget {
  const _SpinnerWithKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary), strokeWidth: 4),
          Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2), width: 4))),
          const Icon(Icons.vpn_key, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

class _UnlockedAssets extends StatelessWidget {
  const _UnlockedAssets();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Akses Legal Diverifikasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('Kunci kriptografi telah disatukan', style: TextStyle(fontSize: 11, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('ASET YANG ANDA WARISI (25%)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.4), letterSpacing: 1.5)),
        const SizedBox(height: 12),
        _InheritedAssetRow(icon: Icons.account_balance, iconColor: Colors.blue, title: 'Rekening BCA', subtitle: 'Bapak Budi Santoso', value: 'Rp 25.000.000', badge: 'Bagian 25%'),
        const SizedBox(height: 12),
        _InheritedAssetRow(icon: Icons.home_work, iconColor: Colors.green, title: 'Sertifikat Rumah', subtitle: 'SHM No. 12345 (Jaksel)', actionLabel: 'Unduh'),
      ],
    );
  }
}

class _InheritedAssetRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? value;
  final String? badge;
  final String? actionLabel;

  const _InheritedAssetRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.value,
    this.badge,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (value != null || badge != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (value != null) Text(value!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                if (badge != null) WtStatusBadge(label: badge!, color: AppColors.primary),
              ],
            ),
          if (actionLabel != null)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: (isDark ? Colors.white : AppColors.navy).withOpacity(0.05),
                foregroundColor: isDark ? Colors.white : AppColors.navy,
                elevation: 0,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
