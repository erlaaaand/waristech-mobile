import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/theme_provider.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/compliance/presentation/screens/consent_status_screen.dart';
import 'package:wt_mobile/features/inheritance/presentation/screens/invitations_screen.dart';
import 'package:wt_mobile/features/users/presentation/screens/edit_profile_screen.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/profil_components.dart';

class PewarisProfilView extends ConsumerWidget {
  final VoidCallback onOpenHeirs;
  final VoidCallback onOpenProtocol;

  const PewarisProfilView({
    super.key,
    required this.onOpenHeirs,
    required this.onOpenProtocol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(name: user?.name ?? '-', email: user?.email ?? '-'),
          const SizedBox(height: 20),

          // ── PERENCANAAN ────────────────────────────────────────────────
          const SectionLabel('Perencanaan Waris'),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.gavel_outlined,
                label: 'Skema Hukum Waris',
                onTap: onOpenHeirs,
              ),
              SettingsRow(
                icon: Icons.verified_user_outlined,
                label: 'Protokol Darurat',
                onTap: onOpenProtocol,
              ),
              SettingsRow(
                icon: Icons.groups_outlined,
                label: 'Undangan Ahli Waris',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const InvitationsScreen(),
                  ),
                ),
                isLast: true,
              ),
            ],
          ),

          // ── AKUN ───────────────────────────────────────────────────────
          const SectionLabel('Akun'),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.person_outline,
                label: 'Edit Profil',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EditProfileScreen(),
                  ),
                ),
              ),
              SettingsRow(
                icon: Icons.privacy_tip_outlined,
                label: 'Persetujuan Data Pribadi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConsentStatusScreen(),
                  ),
                ),
                isLast: true,
              ),
            ],
          ),

          // ── PREFERENSI ─────────────────────────────────────────────────
          const SectionLabel('Preferensi'),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: isDark ? Icons.light_mode_outlined : Icons.contrast,
                label: 'Tema',
                value: isDark ? 'Gelap' : 'Terang',
                onTap: () => ref.read(themeProvider.notifier).toggle(context),
                isLast: true,
              ),
            ],
          ),

          // ── RIWAYAT AKTIVITAS ──────────────────────────────────────────
          const SectionLabel('Riwayat Aktivitas'),
          const ActivityTimeline(),

          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.logout,
                label: 'Keluar',
                isMuted: true,
                onTap: () async => ref.read(authProvider.notifier).logout(),
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
