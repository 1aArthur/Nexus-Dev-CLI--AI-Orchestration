import '../api/generated/contracts.dart';
import '../../features/missions/domain/mission.dart';

final class CachedMissionSnapshot {
  const CachedMissionSnapshot({required this.remoteVersion, required this.isStale});

  final int remoteVersion;
  final bool isStale;
}

final class NexusDatabase {
  NexusDatabase.memory();

  Future<void> cacheMission(
    Mission mission, {
    required DateTime cachedAt,
    required int remoteVersion,
  }) => throw UnimplementedError();

  Future<CachedMissionSnapshot?> readMission(
    String id, {
    required DateTime now,
    required Duration maxAge,
  }) => throw UnimplementedError();

  Future<void> appendMissionEvent(MissionEventDto event) =>
      throw UnimplementedError();

  Future<void> saveDraft(MissionDraft draft) => throw UnimplementedError();

  Future<MissionDraft?> readDraft(String id) => throw UnimplementedError();

  Future<void> recordConflict(
    String id, {
    required String remotePayloadJson,
    required int remoteVersion,
  }) => throw UnimplementedError();

  Future<void> close() async {}
}
