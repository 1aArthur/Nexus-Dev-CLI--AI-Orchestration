import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../api/generated/contracts.dart';
import '../../features/missions/domain/mission.dart';
import 'tables.dart';

final class CachedMissionSnapshot {
  const CachedMissionSnapshot({
    required this.mission,
    required this.remoteVersion,
    required this.isStale,
  });

  final Mission mission;
  final int remoteVersion;
  final bool isStale;
}

final class NexusDatabase {
  NexusDatabase._(this._database) {
    for (final statement in NexusSchema.statements) {
      _database.execute(statement);
    }
  }

  factory NexusDatabase.memory() => NexusDatabase._(sqlite3.openInMemory());

  factory NexusDatabase.open(String path) =>
      NexusDatabase._(sqlite3.open(path));

  final Database _database;

  Future<void> cacheMission(
    Mission mission, {
    required DateTime cachedAt,
    required int remoteVersion,
  }) async {
    _database.execute(
      '''
        INSERT INTO cached_missions
          (id, payload_json, cached_at_ms, remote_version)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          payload_json = excluded.payload_json,
          cached_at_ms = excluded.cached_at_ms,
          remote_version = excluded.remote_version
      ''',
      <Object?>[
        mission.id,
        jsonEncode(mission.toDto().toJson()),
        cachedAt.toUtc().millisecondsSinceEpoch,
        remoteVersion,
      ],
    );
  }

  Future<CachedMissionSnapshot?> readMission(
    String id, {
    required DateTime now,
    required Duration maxAge,
  }) async {
    final rows = _database.select(
      'SELECT payload_json, cached_at_ms, remote_version '
      'FROM cached_missions WHERE id = ?',
      <Object?>[id],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(
      row['cached_at_ms'] as int,
      isUtc: true,
    );
    final payload = jsonDecode(row['payload_json'] as String) as Map;
    return CachedMissionSnapshot(
      mission: Mission.fromDto(MissionDto.fromJson(JsonMap.from(payload))),
      remoteVersion: row['remote_version'] as int,
      isStale: now.toUtc().difference(cachedAt) > maxAge,
    );
  }

  Future<void> appendMissionEvent(MissionEventDto event) async {
    final rows = _database.select(
      'SELECT MAX(sequence) AS last_sequence FROM mission_events '
      'WHERE mission_id = ?',
      <Object?>[event.missionId],
    );
    final lastSequence = rows.single['last_sequence'] as int?;
    if (lastSequence != null && event.sequence <= lastSequence) {
      throw StateError('Mission event sequences must increase');
    }
    _database.execute(
      'INSERT INTO mission_events (mission_id, sequence, payload_json) '
      'VALUES (?, ?, ?)',
      <Object?>[event.missionId, event.sequence, jsonEncode(event.toJson())],
    );
  }

  Future<void> saveDraft(MissionDraft draft) async {
    _database.execute(
      '''
        INSERT INTO mission_drafts (
          id, title, execution_target_id, updated_at_ms,
          base_remote_version, local_payload_json,
          conflict_remote_payload_json, conflict_remote_version
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          title = excluded.title,
          execution_target_id = excluded.execution_target_id,
          updated_at_ms = excluded.updated_at_ms,
          base_remote_version = excluded.base_remote_version,
          local_payload_json = excluded.local_payload_json,
          conflict_remote_payload_json = excluded.conflict_remote_payload_json,
          conflict_remote_version = excluded.conflict_remote_version
      ''',
      <Object?>[
        draft.id,
        draft.title,
        draft.executionTargetId,
        draft.updatedAt.toUtc().millisecondsSinceEpoch,
        draft.baseRemoteVersion,
        draft.localPayloadJson,
        draft.conflictRemotePayloadJson,
        draft.conflictRemoteVersion,
      ],
    );
  }

  Future<MissionDraft?> readDraft(String id) async {
    final rows = _database.select(
      'SELECT * FROM mission_drafts WHERE id = ?',
      <Object?>[id],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return MissionDraft(
      id: row['id'] as String,
      title: row['title'] as String,
      executionTargetId: row['execution_target_id'] as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['updated_at_ms'] as int,
        isUtc: true,
      ),
      baseRemoteVersion: row['base_remote_version'] as int,
      localPayloadJson: row['local_payload_json'] as String,
      conflictRemotePayloadJson: row['conflict_remote_payload_json'] as String?,
      conflictRemoteVersion: row['conflict_remote_version'] as int?,
    );
  }

  Future<void> recordConflict(
    String id, {
    required String remotePayloadJson,
    required int remoteVersion,
  }) async {
    final draft = await readDraft(id);
    if (draft == null) throw StateError('Draft does not exist: $id');
    await saveDraft(
      draft.withConflict(
        remotePayloadJson: remotePayloadJson,
        remoteVersion: remoteVersion,
      ),
    );
  }

  Future<void> close() async {
    _database.close();
  }
}
