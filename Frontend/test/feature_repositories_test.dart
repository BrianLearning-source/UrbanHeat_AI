import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbanheat_ai/data/models/planning_model.dart';
import 'package:urbanheat_ai/data/repositories/notification_repository.dart';
import 'package:urbanheat_ai/data/repositories/planning_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationRepository', () {
    test(
      'keeps notification caches separate for authenticated accounts',
      () async {
        SharedPreferences.setMockInitialValues({
          'urbanheat_notifications_account-a': '[${_notificationJson('a-1')}]',
          'urbanheat_notifications_account-b': '[${_notificationJson('b-1')}]',
        });
        final preferences = await SharedPreferences.getInstance();

        final accountA = NotificationRepository(
          preferences: preferences,
          remoteStore: FakeNotificationRemoteStore(
            userId: 'account-a',
            failFetch: true,
          ),
        );
        final accountB = NotificationRepository(
          preferences: preferences,
          remoteStore: FakeNotificationRemoteStore(
            userId: 'account-b',
            failFetch: true,
          ),
        );

        expect((await accountA.loadNotifications()).single.id, 'a-1');
        expect((await accountB.loadNotifications()).single.id, 'b-1');
      },
    );

    test('uses the guest namespace and provides demo notifications', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = NotificationRepository(
        preferences: preferences,
        remoteStore: FakeNotificationRemoteStore(),
      );

      final notifications = await repository.loadNotifications();

      expect(notifications, hasLength(3));
      expect(preferences.getString('urbanheat_notifications_guest'), isNotNull);
    });

    test('works in guest mode before Supabase is initialized', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = NotificationRepository(preferences: preferences);

      expect(await repository.loadNotifications(), hasLength(3));
    });

    test(
      'remote empty results replace cached and demo notifications',
      () async {
        SharedPreferences.setMockInitialValues({
          'urbanheat_notifications_account-a': '[${_notificationJson('old')}]',
        });
        final preferences = await SharedPreferences.getInstance();
        final repository = NotificationRepository(
          preferences: preferences,
          remoteStore: FakeNotificationRemoteStore(userId: 'account-a'),
        );

        expect(await repository.loadNotifications(), isEmpty);
        expect(
          preferences.getString('urbanheat_notifications_account-a'),
          '[]',
        );
      },
    );

    test('read updates are remotely scoped and locally persisted', () async {
      SharedPreferences.setMockInitialValues({
        'urbanheat_notifications_account-a': '[${_notificationJson('n-1')}]',
      });
      final preferences = await SharedPreferences.getInstance();
      final remote = FakeNotificationRemoteStore(userId: 'account-a');
      final repository = NotificationRepository(
        preferences: preferences,
        remoteStore: remote,
      );

      expect(
        await repository.markAsRead('n-1'),
        NotificationWriteResult.synced,
      );
      expect(remote.readIds, ['n-1']);
      expect(remote.readUsers, ['account-a']);
      expect(
        preferences
            .getString('urbanheat_notifications_account-a')
            ?.contains('"is_read":true'),
        isTrue,
      );

      expect(await repository.markAllAsRead(), NotificationWriteResult.synced);
      expect(remote.markAllUsers, ['account-a']);
      expect(
        preferences
            .getString('urbanheat_notifications_account-a')
            ?.contains('"is_read":false'),
        isFalse,
      );
    });

    test(
      'remote read errors fall back to local state without throwing',
      () async {
        SharedPreferences.setMockInitialValues({
          'urbanheat_notifications_account-a': '[${_notificationJson('n-1')}]',
        });
        final preferences = await SharedPreferences.getInstance();
        final remote =
            FakeNotificationRemoteStore(userId: 'account-a', failWrites: true)
              ..notifications.add(
                jsonDecode(_notificationJson('n-1')) as Map<String, dynamic>,
              );
        final repository = NotificationRepository(
          preferences: preferences,
          remoteStore: remote,
        );

        expect(
          await repository.markAsRead('n-1'),
          NotificationWriteResult.localOnly,
        );
        expect(
          preferences
              .getString('urbanheat_notifications_account-a')
              ?.contains('"is_read":true'),
          isTrue,
        );
        expect((await repository.loadNotifications()).single.isRead, isTrue);
      },
    );
  });

  group('PlanningRepository', () {
    test('keeps planning caches separate for authenticated accounts', () async {
      SharedPreferences.setMockInitialValues({
        'urbanheat_plannings_account-a': '[${_planningJson('a-1', 'A')}]',
        'urbanheat_plannings_account-b': '[${_planningJson('b-1', 'B')}]',
      });
      final preferences = await SharedPreferences.getInstance();
      final accountA = PlanningRepository(
        preferences: preferences,
        remoteStore: FakePlanningRemoteStore(
          userId: 'account-a',
          failFetch: true,
        ),
      );
      final accountB = PlanningRepository(
        preferences: preferences,
        remoteStore: FakePlanningRemoteStore(
          userId: 'account-b',
          failFetch: true,
        ),
      );

      expect((await accountA.loadPlannings()).single.id, 'a-1');
      expect((await accountB.loadPlannings()).single.id, 'b-1');
    });

    test('guest planning uses guest cache and demo data', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = PlanningRepository(
        preferences: preferences,
        remoteStore: FakePlanningRemoteStore(),
      );

      expect(await repository.loadPlannings(), hasLength(3));
      expect(preferences.getString('urbanheat_plannings_guest'), isNotNull);
    });

    test(
      'supports remote planning insert, update, completion, and delete',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final remote = FakePlanningRemoteStore(userId: 'account-a');
        final repository = PlanningRepository(
          preferences: preferences,
          remoteStore: remote,
        );
        final now = DateTime.now();
        final newItem = PlanningItem(
          id: 'temporary-id',
          userId: 'untrusted-user-value',
          title: 'Review hotspot',
          description: '',
          scheduledAt: now.add(const Duration(days: 1)),
          status: PlanningStatus.upcoming,
          createdAt: now,
          updatedAt: now,
        );

        expect(
          await repository.savePlanning(newItem),
          PlanningWriteResult.synced,
        );
        expect(remote.insertUsers, ['account-a']);
        final inserted = (await repository.loadPlannings()).single;
        expect(inserted.id, 'remote-1');
        expect(inserted.userId, 'account-a');

        expect(
          await repository.savePlanning(inserted.copyWith(title: 'Updated')),
          PlanningWriteResult.synced,
        );
        expect(remote.updateIds, ['remote-1']);
        expect(remote.updateUsers, ['account-a']);

        expect(
          await repository.markCompleted('remote-1'),
          PlanningWriteResult.synced,
        );
        expect(remote.completedIds, ['remote-1']);
        expect(remote.completedUsers, ['account-a']);
        expect(
          (await repository.loadPlannings()).single.status,
          PlanningStatus.completed,
        );

        expect(
          await repository.deletePlanning('remote-1'),
          PlanningWriteResult.synced,
        );
        expect(remote.deletedIds, ['remote-1']);
        expect(remote.deletedUsers, ['account-a']);
      },
    );

    test('empty remote results do not show cached account data', () async {
      SharedPreferences.setMockInitialValues({
        'urbanheat_plannings_account-a':
            '[${_planningJson('cached', 'Cached')}]',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = PlanningRepository(
        preferences: preferences,
        remoteStore: FakePlanningRemoteStore(userId: 'account-a'),
      );

      expect(await repository.loadPlannings(), isEmpty);
      expect(preferences.getString('urbanheat_plannings_account-a'), '[]');
    });

    test('empty remote results preserve pending local upserts', () async {
      SharedPreferences.setMockInitialValues({
        'urbanheat_plannings_account-a':
            '[${_planningJson('local-1', 'Offline planning')}]',
        'urbanheat_plannings_pending_account-a': '{"local-1":"upsert"}',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = PlanningRepository(
        preferences: preferences,
        remoteStore: FakePlanningRemoteStore(userId: 'account-a'),
      );

      final plannings = await repository.loadPlannings();

      expect(plannings.single.id, 'local-1');
      expect(plannings.single.title, 'Offline planning');
      expect(
        preferences.getString('urbanheat_plannings_pending_account-a'),
        '{"local-1":"upsert"}',
      );
    });

    test('empty remote results hide pending local deletes', () async {
      SharedPreferences.setMockInitialValues({
        'urbanheat_plannings_account-a':
            '[${_planningJson('local-1', 'Deleted planning')}]',
        'urbanheat_plannings_pending_account-a': '{"local-1":"delete"}',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = PlanningRepository(
        preferences: preferences,
        remoteStore: FakePlanningRemoteStore(userId: 'account-a'),
      );

      expect(await repository.loadPlannings(), isEmpty);
      expect(
        preferences.getString('urbanheat_plannings_pending_account-a'),
        '{"local-1":"delete"}',
      );
    });

    test(
      'remote errors preserve local CRUD fallback without throwing',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final remote =
            FakePlanningRemoteStore(
                userId: 'account-a',
                failFetch: true,
                failWrites: true,
              )
              ..rows.add(
                jsonDecode(_planningJson('local-1', 'Stale remote value'))
                    as Map<String, dynamic>,
              );
        final repository = PlanningRepository(
          preferences: preferences,
          remoteStore: remote,
        );
        final now = DateTime.now();
        final item = PlanningItem(
          id: 'local-1',
          userId: 'account-a',
          title: 'Local fallback',
          description: '',
          scheduledAt: now.add(const Duration(days: 1)),
          status: PlanningStatus.upcoming,
          createdAt: now,
          updatedAt: now,
        );

        expect(await repository.loadPlannings(), isEmpty);
        expect(
          await repository.savePlanning(item),
          PlanningWriteResult.localOnly,
        );
        expect(
          (await repository.loadPlannings()).single.title,
          'Local fallback',
        );
        remote.failFetch = false;
        expect(
          (await repository.loadPlannings()).single.title,
          'Local fallback',
        );
        expect(
          await repository.markCompleted('local-1'),
          PlanningWriteResult.localOnly,
        );
        expect(
          (await repository.loadPlannings()).single.status,
          PlanningStatus.completed,
        );
        expect(
          await repository.deletePlanning('local-1'),
          PlanningWriteResult.localOnly,
        );
        expect(await repository.loadPlannings(), isEmpty);
      },
    );
  });

  test('works in guest mode before Supabase is initialized', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = PlanningRepository(preferences: preferences);

    expect(await repository.loadPlannings(), hasLength(3));
  });
}

String _notificationJson(String id) =>
    '{"id":"$id","user_id":"account-a","title":"Alert","message":"Message",'
    '"type":"general","is_read":false,"created_at":"2026-01-01T00:00:00Z"}';

String _planningJson(String id, String title) =>
    '{"id":"$id","user_id":"account-a","title":"$title","description":"",'
    '"scheduled_at":"2026-01-02T00:00:00Z","status":"upcoming",'
    '"created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z"}';

class FakeNotificationRemoteStore implements NotificationRemoteStore {
  FakeNotificationRemoteStore({
    this.userId,
    this.failFetch = false,
    this.failWrites = false,
  });

  final String? userId;
  final bool failFetch;
  final bool failWrites;
  final List<String> readIds = [];
  final List<String> readUsers = [];
  final List<String> markAllUsers = [];
  final List<Map<String, dynamic>> notifications = [];

  @override
  String? get authenticatedUserId => userId;

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    if (failFetch) throw Exception('network unavailable');
    return notifications;
  }

  @override
  Future<void> markNotificationRead(String id, String userId) async {
    if (failWrites) throw Exception('permission denied');
    readIds.add(id);
    readUsers.add(userId);
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    if (failWrites) throw Exception('permission denied');
    markAllUsers.add(userId);
  }
}

class FakePlanningRemoteStore implements PlanningRemoteStore {
  FakePlanningRemoteStore({
    this.userId,
    this.failFetch = false,
    this.failWrites = false,
  });

  final String? userId;
  bool failFetch;
  final bool failWrites;
  final List<Map<String, dynamic>> rows = [];
  final List<String> insertUsers = [];
  final List<String> updateIds = [];
  final List<String> updateUsers = [];
  final List<String> deletedIds = [];
  final List<String> deletedUsers = [];
  final List<String> completedIds = [];
  final List<String> completedUsers = [];

  @override
  String? get authenticatedUserId => userId;

  @override
  Future<List<Map<String, dynamic>>> fetchPlannings(String userId) async {
    if (failFetch) throw Exception('network unavailable');
    return rows.where((row) => row['user_id'] == userId).toList();
  }

  @override
  Future<Map<String, dynamic>> insertPlanning(
    PlanningItem item,
    String userId,
  ) async {
    _failIfNeeded();
    insertUsers.add(userId);
    final row = item.toJson()
      ..['id'] = 'remote-${insertUsers.length}'
      ..['user_id'] = userId;
    rows.add(row);
    return row;
  }

  @override
  Future<Map<String, dynamic>?> updatePlanning(
    PlanningItem item,
    String userId,
  ) async {
    _failIfNeeded();
    updateIds.add(item.id);
    updateUsers.add(userId);
    for (var index = 0; index < rows.length; index++) {
      if (rows[index]['id'] == item.id && rows[index]['user_id'] == userId) {
        final row = item.toJson()..['user_id'] = userId;
        rows[index] = row;
        return row;
      }
    }
    return null;
  }

  @override
  Future<void> deletePlanning(String id, String userId) async {
    _failIfNeeded();
    deletedIds.add(id);
    deletedUsers.add(userId);
    rows.removeWhere((row) => row['id'] == id && row['user_id'] == userId);
  }

  @override
  Future<bool> markPlanningCompleted(
    String id,
    String userId,
    DateTime updatedAt,
  ) async {
    _failIfNeeded();
    completedIds.add(id);
    completedUsers.add(userId);
    for (final row in rows) {
      if (row['id'] == id && row['user_id'] == userId) {
        row['status'] = PlanningStatus.completed.value;
        row['updated_at'] = updatedAt.toIso8601String();
        return true;
      }
    }
    return false;
  }

  void _failIfNeeded() {
    if (failWrites) throw Exception('permission denied');
  }
}
