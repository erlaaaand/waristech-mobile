import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:wt_mobile/features/notifications/presentation/providers/notification_provider.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? phone;
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Profil',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.gray800 : AppColors.gray100,
                border: Border.all(
                  color: isDark ? AppColors.gray700 : AppColors.gray200,
                  width: 3,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : AppColors.gray600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
          if (phone != null && phone!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              phone!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.gray400,
          letterSpacing: 0.66,
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(children: children),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isLast;
  final bool isMuted;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.isLast = false,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isMuted
        ? AppColors.gray400
        : (isDark ? Colors.white : AppColors.primaryDeep);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.gray800 : AppColors.gray100,
                  ),
                ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Icon(
                icon,
                size: 20,
                color: isMuted ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: const TextStyle(fontSize: 13, color: AppColors.gray400),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray300),
          ],
        ),
      ),
    );
  }
}

class ActivityTimeline extends ConsumerWidget {
  const ActivityTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return notificationsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.danger, fontSize: 12),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'Belum ada aktivitas tercatat.',
              style: TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 2,
                  color: isDark ? AppColors.gray800 : AppColors.gray200,
                ),
              ),
              Column(
                children: [
                  for (int i = 0; i < items.length; i++)
                    NotificationTimelineItem(
                      entry: items[i],
                      isLast: i == items.length - 1,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationTimelineItem extends StatelessWidget {
  final NotificationEntity entry;
  final bool isLast;
  const NotificationTimelineItem({
    super.key,
    required this.entry,
    required this.isLast,
  });

  (IconData, bool) _dotFor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return (Icons.check, true);
      case NotificationType.warning:
        return (Icons.priority_high, false);
      case NotificationType.error:
        return (Icons.priority_high, false);
      case NotificationType.info:
        return (Icons.radio_button_checked, false);
    }
  }

  String _formatTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm • ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, isOk) = _dotFor(entry.type);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkBackground : Colors.white,
              border: Border.all(
                color: isOk
                    ? (isDark ? Colors.white70 : AppColors.gray700)
                    : (isDark ? AppColors.gray700 : AppColors.gray300),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 12,
              color: isDark ? Colors.white70 : AppColors.gray600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(entry.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.message,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
