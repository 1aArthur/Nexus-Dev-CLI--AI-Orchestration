import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/core/api/generated/contracts.dart';
import 'package:nexus_mobile/core/storage/nexus_database.dart';
import 'package:nexus_mobile/features/missions/domain/mission.dart';

void main() {
  late NexusDatabase database;

  setUp(() {
    database = NexusDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  test('cached mission reports freshness from the caller clock', () async {
    final cachedAt = DateTime.utc(2026, 8, 20, 12);
    await database.cacheMission(
      _mission(),
      cachedAt: cachedAt,
      remoteVersion: 3,
    );

    final fresh = await database.readMission(
      _mission().id,
      now: cachedAt.add(const Duration(minutes: 4)),
      maxAge: const Duration(minutes: 5),
    );
    final stale = await database.readMission(
      _mission().id,
      now: cachedAt.add(const Duration(minutes: 6)),
      maxAge: const Duration(minutes: 5),
    );

    expect(fresh?.isStale, isFalse);
    expect(stale?.isStale, isTrue);
    expect(stale?.remoteVersion, 3);
  });

  test('mission event sequence must increase monotonically', () async {
    await database.appendMissionEvent(_event(sequence: 2));

    expect(
      () => database.appendMissionEvent(_event(sequence: 2)),
      throwsStateError,
    );
    expect(
      () => database.appendMissionEvent(_event(sequence: 1)),
      throwsStateError,
    );
    await database.appendMissionEvent(_event(sequence: 3));
  });

  test('draft conflicts preserve both local and remote versions', () async {
    final draft = MissionDraft(
      id: 'draft-1',
      title: 'Local title',
      executionTargetId: '726c761d-7b4d-42a8-a18d-f7bf46e4210d',
      updatedAt: DateTime.utc(2026, 8, 20, 12),
      baseRemoteVersion: 4,
      localPayloadJson: '{"title":"Local title"}',
    );
    await database.saveDraft(draft);
    await database.recordConflict(
      draft.id,
      remotePayloadJson: '{"title":"Remote title"}',
      remoteVersion: 5,
    );

    final stored = await database.readDraft(draft.id);

    expect(stored?.localPayloadJson, '{"title":"Local title"}');
    expect(stored?.conflictRemotePayloadJson, '{"title":"Remote title"}');
    expect(stored?.conflictRemoteVersion, 5);
  });
}

Mission _mission() => Mission.fromDto(
  MissionDto(
    id: '3de4ae3b-b0de-4e1c-a70a-30c6823d6f13',
    ownerId: '782458e7-6fe5-4b08-a47e-a3823738b581',
    title: 'Release Nexus',
    status: MissionStatus.running,
    createdAt: DateTime.utc(2026, 8, 20),
    updatedAt: DateTime.utc(2026, 8, 20, 1),
    lastEventSequence: 2,
  ),
);

MissionEventDto _event({required int sequence}) => MissionEventDto(
  eventId: 'event-$sequence',
  missionId: _mission().id,
  sequence: sequence,
  traceId: 'trace-1234567890',
  type: 'mission.status_changed',
  occurredAt: DateTime.utc(2026, 8, 20, 12, sequence),
  payload: const <String, Object?>{'from': 'queued', 'to': 'running'},
);
