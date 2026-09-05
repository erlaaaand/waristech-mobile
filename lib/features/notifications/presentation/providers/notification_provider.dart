import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:wt_mobile/features/notifications/domain/entities/notification_entity.dart';

final _ds = NotificationRemoteDataSource();

/// Daftar notifikasi/aktivitas milik user yang sedang login.
final myNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
      final raw = await _ds.getMyNotifications();
      return raw
          .whereType<Map<String, dynamic>>()
          .map(NotificationEntity.fromJson)
          .toList();
    });
