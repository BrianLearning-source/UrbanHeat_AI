// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/planning_model.dart';

enum PlanningWriteResult { synced, localOnly }

abstract interface class PlanningRemoteStore {
  String? get authenticatedUserId;

  Future<List<Map<String, dynamic>>> fetchPlannings(String userId);

  Future<Map<String, dynamic>> insertPlanning(PlanningItem item, String userId);

  Future<Map<String, dynamic>?> updatePlanning(
    PlanningItem item,
    String userId,
  );

  Future<void> deletePlanning(String id, String userId);

  Future<bool> markPlanningCompleted(
    String id,
    String userId,
    DateTime updatedAt,
  );
}

class SupabasePlanningRemoteStore implements PlanningRemoteStore {
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
  Future<List<Map<String, dynamic>>> fetchPlannings(String userId) async {
    final response = await _requiredClient
        .from('user_plannings')
        .select()
        .eq('user_id', userId)
        .order('scheduled_at', ascending: true);
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> insertPlanning(
    PlanningItem item,
    String userId,
  ) async {
    final response = await _requiredClient
        .from('user_plannings')
        .insert(_writePayload(item, userId))
        .select()
        .single();
    return response;
  }

  @override
  Future<Map<String, dynamic>?> updatePlanning(
    PlanningItem item,
    String userId,
  ) async {
    final response = await _requiredClient
        .from('user_plannings')
        .update(_writePayload(item, userId)..remove('created_at'))
        .eq('id', item.id)
        .eq('user_id', userId)
        .select()
        .maybeSingle();
    return response;
  }

  @override
  Future<void> deletePlanning(String id, String userId) async {
    final response = await _requiredClient
        .from('user_plannings')
        .delete()
        .eq('id', id)
        .eq('user_id', userId)
        .select('id');
    if ((response as List).isEmpty) {
      throw StateError('The planning record was not found for this user.');
    }
  }

  @override
  Future<bool> markPlanningCompleted(
    String id,
    String userId,
    DateTime updatedAt,
  ) async {
    final response = await _requiredClient
        .from('user_plannings')
        .update({
          'status': PlanningStatus.completed.value,
          'updated_at': updatedAt.toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', userId)
        .select('id')
        .maybeSingle();
    return response != null;
  }

  Map<String, dynamic> _writePayload(PlanningItem item, String userId) => {
    'user_id': userId,
    'title': item.title,
    'description': item.description,
    'scheduled_at': item.scheduledAt.toIso8601String(),
    'status': item.status.value,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.updatedAt.toIso8601String(),
  };

  SupabaseClient get _requiredClient {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not initialized.');
    }
    return client;
  }
}

class PlanningRepository {
  PlanningRepository({
    SharedPreferences? preferences,
    PlanningRemoteStore? remoteStore,
  }) : _preferences = preferences,
       _remoteStore = remoteStore ?? SupabasePlanningRemoteStore();

  final SharedPreferences? _preferences;
  final PlanningRemoteStore _remoteStore;

  Future<SharedPreferences> get _storage async =>
      _preferences ?? await SharedPreferences.getInstance();

  String _storageKey(String? userId) =>
      'urbanheat_plannings_${userId ?? 'guest'}';

  String _pendingKey(String userId) => 'urbanheat_plannings_pending_$userId';

  List<PlanningItem> get _seedPlannings => [
    PlanningItem(
      id: 'p-1',
      userId: 'guest',
      title: 'Review mitigation notes',
      description:
          'Summarize the hottest corridor findings and ranking update.',
      scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 3)),
      status: PlanningStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PlanningItem(
      id: 'p-2',
      userId: 'guest',
      title: 'Canopy impact check',
      description: 'Inspect the shading density across commercial nodes.',
      scheduledAt: DateTime.now().add(const Duration(days: 4)),
      status: PlanningStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PlanningItem(
      id: 'p-3',
      userId: 'guest',
      title: 'Report final recommendation',
      description:
          'Finalize the mitigation brief for the next stakeholder review.',
      scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
      status: PlanningStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<PlanningItem>> loadPlannings() async {
    final userId = _remoteStore.authenticatedUserId;
    if (userId != null) {
      try {
        final response = await _remoteStore.fetchPlannings(userId);
        final remotePlannings = response.map(PlanningItem.fromJson).toList();
        final pending = await _readPending(userId);
        final local = await _readLocalPlannings(userId);
        final localById = {for (final item in local) item.id: item};
        final remoteById = {for (final item in remotePlannings) item.id: item};

        final planningsById = {...remoteById};
        for (final entry in pending.entries) {
          if (entry.value == 'delete') {
            planningsById.remove(entry.key);
          } else {
            final localItem = localById[entry.key];
            if (localItem != null) {
              planningsById[entry.key] = localItem;
            }
          }
        }
        final plannings = planningsById.values.toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        await _persistLocal(plannings, userId);
        return plannings;
      } catch (error) {
        debugPrint(
          'Unable to load remote plannings; using account cache: $error',
        );
        return _readLocalPlannings(userId);
      }
    }

    final localPlannings = await _readLocalPlannings(null);
    if (localPlannings.isNotEmpty) {
      return localPlannings;
    }

    final seeded = _seedPlannings;
    await _persistLocal(seeded, null);
    return seeded;
  }

  Future<PlanningWriteResult> savePlanning(PlanningItem item) async {
    final userId = _remoteStore.authenticatedUserId;
    final existing = await _readLocalPlannings(userId);
    final existingIndex = existing.indexWhere(
      (planning) => planning.id == item.id,
    );

    if (userId != null) {
      try {
        final saved = existingIndex >= 0
            ? await _remoteStore.updatePlanning(item, userId)
            : await _remoteStore.insertPlanning(item, userId);
        if (saved == null) {
          throw StateError('The planning record was not found for this user.');
        }

        final persistedItem = PlanningItem.fromJson(saved);
        if (existingIndex >= 0) {
          existing[existingIndex] = persistedItem;
        } else {
          existing.add(persistedItem);
        }
        await _persistLocal(existing, userId);
        await _removePending(userId, item.id);
        return PlanningWriteResult.synced;
      } catch (error) {
        debugPrint('Unable to save remote planning; saving locally: $error');
      }
    }

    final localItem = userId == null ? item : item.copyWith(userId: userId);
    if (existingIndex >= 0) {
      existing[existingIndex] = localItem;
    } else {
      existing.add(localItem);
    }
    if (userId != null) {
      await _setPending(userId, item.id, 'upsert');
    }
    await _persistLocal(existing, userId);
    return PlanningWriteResult.localOnly;
  }

  Future<PlanningWriteResult> deletePlanning(String id) async {
    final userId = _remoteStore.authenticatedUserId;
    var synced = false;
    if (userId != null) {
      try {
        await _remoteStore.deletePlanning(id, userId);
        synced = true;
        await _removePending(userId, id);
      } catch (error) {
        debugPrint(
          'Unable to delete remote planning; removing local copy: $error',
        );
      }
    }

    final plannings = await _readLocalPlannings(userId);
    final updated = plannings.where((planning) => planning.id != id).toList();
    if (userId != null && !synced) {
      await _setPending(userId, id, 'delete');
    }
    await _persistLocal(updated, userId);
    return synced ? PlanningWriteResult.synced : PlanningWriteResult.localOnly;
  }

  Future<PlanningWriteResult> markCompleted(String id) async {
    final userId = _remoteStore.authenticatedUserId;
    final plannings = await _readLocalPlannings(userId);
    final index = plannings.indexWhere((planning) => planning.id == id);
    if (index < 0) return PlanningWriteResult.localOnly;

    final updatedAt = DateTime.now();
    var synced = false;
    if (userId != null) {
      try {
        synced = await _remoteStore.markPlanningCompleted(
          id,
          userId,
          updatedAt,
        );
        if (!synced) {
          throw StateError('The planning record was not found for this user.');
        }
        await _removePending(userId, id);
      } catch (error) {
        debugPrint(
          'Unable to complete remote planning; saving locally: $error',
        );
        synced = false;
      }
    }

    plannings[index] = plannings[index].copyWith(
      status: PlanningStatus.completed,
      updatedAt: updatedAt,
    );
    if (userId != null && !synced) {
      await _setPending(userId, id, 'upsert');
    }
    await _persistLocal(plannings, userId);
    return synced ? PlanningWriteResult.synced : PlanningWriteResult.localOnly;
  }

  Future<void> _persistLocal(
    List<PlanningItem> plannings,
    String? userId,
  ) async {
    final storage = await _storage;
    final payload = jsonEncode(
      plannings.map((planning) => planning.toJson()).toList(),
    );
    await storage.setString(_storageKey(userId), payload);
  }

  Future<List<PlanningItem>> _readLocalPlannings(String? userId) async {
    final storage = await _storage;
    final encoded = storage.getString(_storageKey(userId));
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final decoded = jsonDecode(encoded) as List;
      return decoded
          .map((json) => PlanningItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException catch (error) {
      debugPrint('Ignoring malformed local planning cache: $error');
      return [];
    } on TypeError catch (error) {
      debugPrint('Ignoring malformed local planning cache: $error');
      return [];
    }
  }

  Future<Map<String, String>> _readPending(String userId) async {
    final storage = await _storage;
    final encoded = storage.getString(_pendingKey(userId));
    if (encoded == null || encoded.isEmpty) return {};
    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } on FormatException catch (error) {
      debugPrint('Ignoring malformed planning sync state: $error');
      return {};
    } on TypeError catch (error) {
      debugPrint('Ignoring malformed planning sync state: $error');
      return {};
    }
  }

  Future<void> _setPending(String userId, String id, String operation) async {
    final pending = await _readPending(userId);
    pending[id] = operation;
    await _writePending(userId, pending);
  }

  Future<void> _removePending(String userId, String id) async {
    final pending = await _readPending(userId);
    pending.remove(id);
    await _writePending(userId, pending);
  }

  Future<void> _writePending(String userId, Map<String, String> pending) async {
    final storage = await _storage;
    if (pending.isEmpty) {
      await storage.remove(_pendingKey(userId));
    } else {
      await storage.setString(_pendingKey(userId), jsonEncode(pending));
    }
  }
}

final planningRepository = PlanningRepository();
