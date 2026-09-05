/// Tipe notifikasi — cocok persis dengan `NotificationType` enum backend.
enum NotificationType {
  info,
  success,
  warning,
  error;

  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SUCCESS':
        return NotificationType.success;
      case 'WARNING':
        return NotificationType.warning;
      case 'ERROR':
        return NotificationType.error;
      default:
        return NotificationType.info;
    }
  }
}

/// Notifikasi/log aktivitas milik user — GET /notifications.
class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? ''),
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
