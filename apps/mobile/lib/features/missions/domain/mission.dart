import '../../../core/api/generated/contracts.dart';

final class Mission {
  const Mission({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.lastEventSequence,
    this.budgetLimitMicros,
    this.concurrencyLimit,
  });

  factory Mission.fromDto(MissionDto dto) => Mission(
    id: dto.id,
    ownerId: dto.ownerId,
    title: dto.title,
    status: dto.status,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
    lastEventSequence: dto.lastEventSequence,
    budgetLimitMicros: dto.budgetLimitMicros,
    concurrencyLimit: dto.concurrencyLimit,
  );

  final String id;
  final String ownerId;
  final String title;
  final MissionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int lastEventSequence;
  final int? budgetLimitMicros;
  final int? concurrencyLimit;

  bool get isTerminal => switch (status) {
    MissionStatus.succeeded ||
    MissionStatus.failed ||
    MissionStatus.cancelled => true,
    _ => false,
  };

  Mission transitionTo(MissionStatus next, {DateTime? at}) {
    if (isTerminal) {
      throw StateError('A terminal mission cannot transition');
    }
    if (!_allowedTransitions[status]!.contains(next)) {
      throw StateError('Invalid mission transition: $status -> $next');
    }
    return Mission(
      id: id,
      ownerId: ownerId,
      title: title,
      status: next,
      createdAt: createdAt,
      updatedAt: at ?? updatedAt,
      lastEventSequence: lastEventSequence,
      budgetLimitMicros: budgetLimitMicros,
      concurrencyLimit: concurrencyLimit,
    );
  }

  MissionDto toDto() => MissionDto(
    id: id,
    ownerId: ownerId,
    title: title,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastEventSequence: lastEventSequence,
    budgetLimitMicros: budgetLimitMicros,
    concurrencyLimit: concurrencyLimit,
  );
}

const _allowedTransitions = <MissionStatus, Set<MissionStatus>>{
  MissionStatus.draft: {MissionStatus.queued, MissionStatus.cancelled},
  MissionStatus.queued: {
    MissionStatus.running,
    MissionStatus.failed,
    MissionStatus.cancelled,
  },
  MissionStatus.running: {
    MissionStatus.awaitingApproval,
    MissionStatus.succeeded,
    MissionStatus.failed,
    MissionStatus.cancelled,
  },
  MissionStatus.awaitingApproval: {
    MissionStatus.running,
    MissionStatus.succeeded,
    MissionStatus.failed,
    MissionStatus.cancelled,
  },
  MissionStatus.succeeded: {},
  MissionStatus.failed: {},
  MissionStatus.cancelled: {},
};

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

  MissionDraft withConflict({
    required String remotePayloadJson,
    required int remoteVersion,
  }) => MissionDraft(
    id: id,
    title: title,
    executionTargetId: executionTargetId,
    updatedAt: updatedAt,
    baseRemoteVersion: baseRemoteVersion,
    localPayloadJson: localPayloadJson,
    conflictRemotePayloadJson: remotePayloadJson,
    conflictRemoteVersion: remoteVersion,
  );
}
