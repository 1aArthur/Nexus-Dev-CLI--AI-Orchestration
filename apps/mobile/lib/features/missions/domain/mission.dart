import '../../../core/api/generated/contracts.dart';

final class Mission {
  const Mission();

  factory Mission.fromDto(MissionDto dto) => throw UnimplementedError();

  String get id => throw UnimplementedError();

  Mission transitionTo(MissionStatus next) => throw UnimplementedError();

  MissionDto toDto() => throw UnimplementedError();
}

final class MissionDraft {
  const MissionDraft({
    required this.id,
    required this.title,
    required this.executionTargetId,
    required this.updatedAt,
    required this.baseRemoteVersion,
    required this.localPayloadJson,
    this.conflictRemotePayloadJson,
    this.conflictRemoteVersion,
  });

  final String id;
  final String title;
  final String executionTargetId;
  final DateTime updatedAt;
  final int baseRemoteVersion;
  final String localPayloadJson;
  final String? conflictRemotePayloadJson;
  final int? conflictRemoteVersion;
}
