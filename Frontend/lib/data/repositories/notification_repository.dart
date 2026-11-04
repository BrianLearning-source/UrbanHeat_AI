// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';

enum NotificationWriteResult { synced, localOnly }

abstract interface class NotificationRemoteStore {
  String? get authenticatedUserId;

  Future<List<Map<String, dynamic>>> fetchNotifications(String userId);

  Future<void> markNotificationRead(String id, String userId);

  Future<void> markAllNotificationsRead(String userId);
}

class SupabaseNotificationRemoteStore implements NotificationRemoteStore {
  SupabaseClient? get _client {
    try {
      final supabase = Supabase.instance;
      return supabase.isInitialized ? supabase.client : null;
    } on AssertionError {
      return null;
    }
  }

  @override
  String? get authenticatedUserId {
    final client = _client;
    if (client?.auth.currentSession == null) return null;
    return client?.auth.currentUser?.id;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    final response = await _requiredClient
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> markNotificationRead(String id, String userId) async {
    final response = await _requiredClient
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id)
        .eq('user_id', userId)
        .select('id');
    if ((response as List).isEmpty) {
      throw StateError('The notification was not found for this user.');
    }
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    await _requiredClient
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  SupabaseClient get _requiredClient {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not initialized.');
    }
    return client;
  }
}

class NotificationRepository {
  NotificationRepository({
    SharedPreferences? preferences,
    NotificationRemoteStore? remoteStore,
  }) : _preferences = preferences,
       _remoteStore = remoteStore ?? SupabaseNotificationRemoteStore();

  final SharedPreferences? _preferences;
  final NotificationRemoteStore _remoteStore;

  Future<SharedPreferences> get _storage async =>
      _preferences ?? await SharedPreferences.getInstance();

  String _storageKey(String? userId) =>
      'urbanheat_notifications_${userId ?? 'guest'}';

  String _pendingKey(String userId) =>
      'urbanheat_notifications_pending_$userId';

  List<AppNotification> get _seedNotifications => [
    AppNotification(
      id: 'n-1',
      userId: 'guest',
      title: 'Heat alert',
      message: 'Lowokwaru grid is trending 1.2°C above the weekly average.',
      type: 'heat_alert',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      targetRoute: '/heatmap',
    ),
    AppNotification(
      id: 'n-2',
      userId: 'guest',
      title: 'Mitigation reminder',
      message: 'Review canopy mitigation actions for the central corridor.',
      type: 'planning',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      targetRoute: '/planning',
    ),
    AppNotification(
      id: 'n-3',
      userId: 'guest',
      title: 'Observation update',
      message: 'The latest satellite scan has been published for review.',
      type: 'system',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      targetRoute: '/heatmap/prediction',
    ),
  ];

  Future<List<AppNotification>> loadNotifications() async {
    final userId = _remoteStore.authenticatedUserId;
    if (userId != null) {
      try {
        final response = await _remoteStore.fetchNotifications(userId);
        final remoteNotifications = response
            .map(AppNotification.fromJson)
            .toList();
        if (remoteNotifications.isEmpty) {
          await _persistLocal([], userId);
          await _clearPending(userId);
          return [];
        }

        final pending = await _readPending(userId);
        final notifications = remoteNotifications.map((notification) {
          if (pending['all'] == true ||
              (pending['ids'] as List? ?? const []).contains(notification.id)) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        await _persistLocal(notifications, userId);
        return notifications;
      } catch (error) {
        debugPrint(
          'Unable to load remote notifications; using account cache: $error',
        );
        return _readLocalNotifications(userId);
      }
    }

    final localNotifications = await _readLocalNotifications(null);
    if (localNotifications.isNotEmpty) {
      return localNotifications;
    }

    final seeded = _seedNotifications;
    await _persistLocal(seeded, null);
    return seeded;
  }

  Future<int> getUnreadCount() async {
    final notifications = await loadNotifications();
    return notifications.where((notification) => !notification.isRead).length;
  }

  Future<NotificationWriteResult> markAsRead(String id) async {
    final userId = _remoteStore.authenticatedUserId;
    var synced = false;
    if (userId != null) {
      try {
        await _remoteStore.markNotificationRead(id, userId);
        synced = true;
        await _removePendingId(userId, id);
      } catch (error) {
        debugPrint(
          'Unable to mark remote notification as read; saving locally: $error',
        );
      }
    }

    final notifications = await _readLocalNotifications(userId);
    final updated = notifications
        .map(
          (notification) => notification.id == id
              ? notification.copyWith(isRead: true)
              : notification,
        )
        .toList();
    if (userId != null && !synced) {
      await _addPendingId(userId, id);
    }
    await _persistLocal(updated, userId);
    return synced
        ? NotificationWriteResult.synced
        : NotificationWriteResult.localOnly;
  }

  Future<NotificationWriteResult> markAllAsRead() async {
    final userId = _remoteStore.authenticatedUserId;
    var synced = false;
    if (userId != null) {
      try {
        await _remoteStore.markAllNotificationsRead(userId);
        synced = true;
        await _clearPending(userId);
      } catch (error) {
        debugPrint(
          'Unable to mark remote notifications as read; saving locally: $error',
        );
      }
    }

    final notifications = await _readLocalNotifications(userId);
    final updated = notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    if (userId != null && !synced) {
      await _writePending(userId, {'all': true, 'ids': <String>[]});
    }
    await _persistLocal(updated, userId);
    return synced
        ? NotificationWriteResult.synced
        : NotificationWriteResult.localOnly;
  }

  Future<void> _persistLocal(
    List<AppNotification> notifications,
    String? userId,
  ) async {
    final storage = await _storage;
    final payload = jsonEncode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
    await storage.setString(_storageKey(userId), payload);
  }

  Future<List<AppNotification>> _readLocalNotifications(String? userId) async {
    final storage = await _storage;
    final encoded = storage.getString(_storageKey(userId));
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final decoded = jsonDecode(encoded) as List;
      return decoded
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException catch (error) {
      debugPrint('Ignoring malformed local notification cache: $error');
      return [];
    } on TypeError catch (error) {
      debugPrint('Ignoring malformed local notification cache: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>> _readPending(String userId) async {
    final storage = await _storage;
    final encoded = storage.getString(_pendingKey(userId));
    if (encoded == null || encoded.isEmpty) {
      return {'all': false, 'ids': <String>[]};
    }
    try {
      return jsonDecode(encoded) as Map<String, dynamic>;
    } on FormatException catch (error) {
      debugPrint('Ignoring malformed notification sync state: $error');
      return {'all': false, 'ids': <String>[]};
    } on TypeError catch (error) {
      debugPrint('Ignoring malformed notification sync state: $error');
      return {'all': false, 'ids': <String>[]};
    }
  }

  Future<void> _addPendingId(String userId, String id) async {
    final pending = await _readPending(userId);
    final ids = Set<String>.from(pending['ids'] as List? ?? const [])..add(id);
    await _writePending(userId, {
      'all': pending['all'] == true,
      'ids': ids.toList(),
    });
  }

  Future<void> _removePendingId(String userId, String id) async {
    final pending = await _readPending(userId);
    final ids = Set<String>.from(pending['ids'] as List? ?? const <String>[])
      ..remove(id);
    await _writePending(userId, {
      'all': pending['all'] == true,
      'ids': ids.toList(),
    });
  }

  Future<void> _writePending(
    String userId,
    Map<String, dynamic> pending,
  ) async {
    final storage = await _storage;
    await storage.setString(_pendingKey(userId), jsonEncode(pending));
  }

  Future<void> _clearPending(String userId) async {
    final storage = await _storage;
    await storage.remove(_pendingKey(userId));
  }
}

final notificationRepository = NotificationRepository();
