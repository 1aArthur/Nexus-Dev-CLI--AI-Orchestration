import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/api/generated/contracts.dart';
import '../domain/mission.dart';

typedef Clock = DateTime Function();
typedef IdempotencyKeyFactory = String Function();

final class MissionModelCapability {
  const MissionModelCapability({
    required this.providerId,
    required this.exactModelId,
    required this.supportedReasoning,
  });

  final String providerId;
  final String exactModelId;
  final Set<UniversalReasoningLevel> supportedReasoning;
}

final class OrchestrationProfile {
  const OrchestrationProfile({
    required this.agentCount,
    required this.concurrency,
    required this.budgetMicros,
    required this.deadline,
    required this.approvalMode,
  });

  final int agentCount;
  final int concurrency;
  final int budgetMicros;
  final DateTime? deadline;
  final ApprovalMode approvalMode;
}

final class MissionConfiguration {
  const MissionConfiguration({
    this.title = '',
    this.executionTargetId = '',
    this.providerId = '',
    this.exactModelId = '',
    this.reasoning = UniversalReasoningLevel.balanced,
    this.agentCount = 4,
    this.concurrency = 2,
    this.budgetMicros = 1000000,
    this.deadline,
    this.approvalMode = ApprovalMode.policy,
  });

  final String title;
  final String executionTargetId;
  final String providerId;
  final String exactModelId;
  final UniversalReasoningLevel reasoning;
  final int agentCount;
  final int concurrency;
  final int budgetMicros;
  final DateTime? deadline;
  final ApprovalMode approvalMode;

  MissionConfiguration copyWith({
    String? title,
    String? executionTargetId,
    String? providerId,
    String? exactModelId,
    UniversalReasoningLevel? reasoning,
    int? agentCount,
    int? concurrency,
    int? budgetMicros,
    DateTime? deadline,
    ApprovalMode? approvalMode,
  }) => MissionConfiguration(
    title: title ?? this.title,
    executionTargetId: executionTargetId ?? this.executionTargetId,
    providerId: providerId ?? this.providerId,
    exactModelId: exactModelId ?? this.exactModelId,
    reasoning: reasoning ?? this.reasoning,
    agentCount: agentCount ?? this.agentCount,
    concurrency: concurrency ?? this.concurrency,
    budgetMicros: budgetMicros ?? this.budgetMicros,
    deadline: deadline ?? this.deadline,
    approvalMode: approvalMode ?? this.approvalMode,
  );
}

final class CostPreview {
  const CostPreview({
    required this.estimatedMicros,
    required this.reservedMicros,
    required this.currency,
  });

  final int estimatedMicros;
  final int reservedMicros;
  final String currency;
}

final class MissionValidation {
  const MissionValidation(this.issues);

  final List<String> issues;
  bool get isValid => issues.isEmpty;
}

enum MissionRuntimeEventType {
  queued,
  running,
  approvalRequired,
  resumed,
  succeeded,
  failed,
  cancelled,
}

final class MissionRuntimeEvent {
  const MissionRuntimeEvent({
    required this.missionId,
    required this.sequence,
    required this.type,
    required this.occurredAt,
    this.agentId,
  });

  final String missionId;
  final int sequence;
  final MissionRuntimeEventType type;
  final DateTime occurredAt;
  final String? agentId;
}

final class ApprovalGate {
  const ApprovalGate({required this.agentId, required this.sequence});

  final String agentId;
  final int sequence;
}

final class MissionControllerState {
  const MissionControllerState({
    required this.draft,
    required this.costPreview,
    this.mission,
    this.lastEventSequence = 0,
    this.hasEventGap = false,
    this.pendingApproval,
    this.isSubmitting = false,
    this.failure,
  });

  final MissionConfiguration draft;
  final CostPreview costPreview;
  final Mission? mission;
  final int lastEventSequence;
  final bool hasEventGap;
  final ApprovalGate? pendingApproval;
  final bool isSubmitting;
  final String? failure;

  MissionControllerState copyWith({
    MissionConfiguration? draft,
    CostPreview? costPreview,
    Mission? mission,
    int? lastEventSequence,
    bool? hasEventGap,
    ApprovalGate? pendingApproval,
    bool clearApproval = false,
    bool? isSubmitting,
    String? failure,
    bool clearFailure = false,
  }) => MissionControllerState(
    draft: draft ?? this.draft,
    costPreview: costPreview ?? this.costPreview,
    mission: mission ?? this.mission,
    lastEventSequence: lastEventSequence ?? this.lastEventSequence,
    hasEventGap: hasEventGap ?? this.hasEventGap,
    pendingApproval: clearApproval
        ? null
        : (pendingApproval ?? this.pendingApproval),
    isSubmitting: isSubmitting ?? this.isSubmitting,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

final class MissionSubmission {
  const MissionSubmission({required this.configuration, required this.profile});

  final MissionConfiguration configuration;
  final OrchestrationProfile profile;
}

abstract interface class MissionGateway {
  Future<Mission> submit(
    MissionSubmission submission, {
    required String idempotencyKey,
  });

  Future<Mission> cancel(String missionId);
  Future<Mission> resume(String missionId);
}

final class InMemoryMissionGateway implements MissionGateway {
  final Map<String, Mission> _submissions = <String, Mission>{};
  int submissionCount = 0;

  @override
  Future<Mission> submit(
    MissionSubmission submission, {
    required String idempotencyKey,
  }) async {
    final existing = _submissions[idempotencyKey];
    if (existing != null) return existing;
    submissionCount += 1;
    final now = DateTime.now().toUtc();
    final mission = Mission(
      id: 'mission-$submissionCount',
      ownerId: 'local-user',
      title: submission.configuration.title,
      status: MissionStatus.queued,
      createdAt: now,
      updatedAt: now,
      lastEventSequence: 0,
      budgetLimitMicros: submission.profile.budgetMicros,
      concurrencyLimit: submission.profile.concurrency,
    );
    _submissions[idempotencyKey] = mission;
    return mission;
  }

  @override
  Future<Mission> cancel(String missionId) async =>
      _replaceStatus(missionId, MissionStatus.cancelled);

  @override
  Future<Mission> resume(String missionId) async =>
      _replaceStatus(missionId, MissionStatus.running);

  Mission _replaceStatus(String missionId, MissionStatus status) {
    final entry = _submissions.entries.where(
      (item) => item.value.id == missionId,
    );
    if (entry.isEmpty) throw StateError('Unknown mission');
    final item = entry.first;
    final mission = item.value;
    final updated = Mission(
      id: mission.id,
      ownerId: mission.ownerId,
      title: mission.title,
      status: status,
      createdAt: mission.createdAt,
      updatedAt: DateTime.now().toUtc(),
      lastEventSequence: mission.lastEventSequence,
      budgetLimitMicros: mission.budgetLimitMicros,
      concurrencyLimit: mission.concurrencyLimit,
    );
    _submissions[item.key] = updated;
    return updated;
  }
}

final class MissionController extends ChangeNotifier {
  MissionController({
    required this.gateway,
    required List<MissionModelCapability> modelCapabilities,
    Clock? now,
    IdempotencyKeyFactory? idempotencyKeyFactory,
  }) : _capabilities = List.unmodifiable(modelCapabilities),
       _now = now ?? DateTime.now,
       _idempotencyKeyFactory =
           idempotencyKeyFactory ??
           (() => 'mission-${DateTime.now().microsecondsSinceEpoch}'),
       _state = const MissionControllerState(
         draft: MissionConfiguration(),
         costPreview: CostPreview(
           estimatedMicros: 480000,
           reservedMicros: 480000,
           currency: 'USD',
         ),
       );

  final MissionGateway gateway;
  final List<MissionModelCapability> _capabilities;
  final Clock _now;
  final IdempotencyKeyFactory _idempotencyKeyFactory;
  MissionControllerState _state;
  String? _submissionKey;
  Future<Mission>? _submission;

  MissionControllerState get state => _state;

  Set<UniversalReasoningLevel> get availableReasoningLevels {
    final selected = _selectedCapability;
    return selected?.supportedReasoning ?? const <UniversalReasoningLevel>{};
  }

  MissionModelCapability? get _selectedCapability {
    for (final capability in _capabilities) {
      if (capability.providerId == _state.draft.providerId &&
          capability.exactModelId == _state.draft.exactModelId) {
        return capability;
      }
    }
    return null;
  }

  void setTitle(String title) => _update(_state.draft.copyWith(title: title));

  void setExecutionTarget(String targetId) =>
      _update(_state.draft.copyWith(executionTargetId: targetId));

  void setAgentCount(int value) {
    final bounded = value.clamp(1, 64).toInt();
    _update(
      _state.draft.copyWith(
        agentCount: bounded,
        concurrency: _state.draft.concurrency.clamp(1, bounded).toInt(),
      ),
    );
  }

  void setConcurrency(int value) => _update(
    _state.draft.copyWith(
      concurrency: value.clamp(1, _state.draft.agentCount).toInt(),
    ),
  );

  void setBudgetMicros(int value) => _update(
    _state.draft.copyWith(budgetMicros: value.clamp(1000, 1000000000).toInt()),
  );

  void setDeadline(DateTime value) =>
      _update(_state.draft.copyWith(deadline: value));

  void setApprovalMode(ApprovalMode value) =>
      _update(_state.draft.copyWith(approvalMode: value));

  void selectModel(String providerId, String exactModelId) {
    var next = _state.draft.copyWith(
      providerId: providerId,
      exactModelId: exactModelId,
    );
    final capability = _capabilities.where(
      (item) =>
          item.providerId == providerId && item.exactModelId == exactModelId,
    );
    if (capability.isNotEmpty &&
        !capability.first.supportedReasoning.contains(next.reasoning)) {
      next = next.copyWith(
        reasoning:
            capability.first.supportedReasoning.contains(
              UniversalReasoningLevel.balanced,
            )
            ? UniversalReasoningLevel.balanced
            : capability.first.supportedReasoning.first,
      );
    }
    _update(next);
  }

  void setReasoning(UniversalReasoningLevel value) {
    if (!availableReasoningLevels.contains(value)) {
      throw StateError(
        'Reasoning level is not supported by the selected model',
      );
    }
    _update(_state.draft.copyWith(reasoning: value));
  }

  MissionValidation validate() {
    final issues = <String>[];
    final draft = _state.draft;
    if (draft.title.trim().length < 3) issues.add('Mission title is required');
    if (draft.executionTargetId.isEmpty) {
      issues.add('Execution target is required');
    }
    if (_selectedCapability == null) {
      issues.add('A supported exact model is required');
    }
    if (draft.deadline != null && !draft.deadline!.isAfter(_now())) {
      issues.add('Deadline must be in the future');
    }
    if (_state.costPreview.reservedMicros > draft.budgetMicros) {
      issues.add('Reserved cost exceeds the hard budget');
    }
    return MissionValidation(List.unmodifiable(issues));
  }

  Future<Mission> submit() {
    if (_submission != null) return _submission!;
    final validation = validate();
    if (!validation.isValid) {
      throw StateError(validation.issues.join('; '));
    }
    _submissionKey ??= _idempotencyKeyFactory();
    _state = _state.copyWith(isSubmitting: true, clearFailure: true);
    notifyListeners();
    final profile = OrchestrationProfile(
      agentCount: _state.draft.agentCount,
      concurrency: _state.draft.concurrency,
      budgetMicros: _state.draft.budgetMicros,
      deadline: _state.draft.deadline,
      approvalMode: _state.draft.approvalMode,
    );
    _submission = gateway
        .submit(
          MissionSubmission(configuration: _state.draft, profile: profile),
          idempotencyKey: _submissionKey!,
        )
        .then((mission) {
          _state = _state.copyWith(mission: mission, isSubmitting: false);
          notifyListeners();
          return mission;
        })
        .catchError((Object error) {
          _submission = null;
          _state = _state.copyWith(isSubmitting: false, failure: '$error');
          notifyListeners();
          throw error;
        });
    return _submission!;
  }

  Future<Mission> cancel() {
    final mission = _state.mission;
    if (mission == null || mission.isTerminal) {
      throw StateError('No cancellable mission');
    }
    return gateway.cancel(mission.id).then(_storeMission);
  }

  Future<Mission> resume() {
    final mission = _state.mission;
    if (mission == null || mission.isTerminal) {
      throw StateError('A terminal or missing mission cannot resume');
    }
    return gateway.resume(mission.id).then(_storeMission);
  }

  Mission _storeMission(Mission mission) {
    _state = _state.copyWith(mission: mission);
    notifyListeners();
    return mission;
  }

  void applyEvent(MissionRuntimeEvent event) {
    final gap = event.sequence != _state.lastEventSequence + 1;
    final current = _state.mission;
    final status = _statusForEvent(event.type);
    final mission = status == null
        ? current
        : Mission(
            id: current?.id ?? event.missionId,
            ownerId: current?.ownerId ?? 'unknown',
            title: current?.title ?? 'Mission',
            status: status,
            createdAt: current?.createdAt ?? event.occurredAt,
            updatedAt: event.occurredAt,
            lastEventSequence: event.sequence,
            budgetLimitMicros: current?.budgetLimitMicros,
            concurrencyLimit: current?.concurrencyLimit,
          );
    final approval = event.type == MissionRuntimeEventType.approvalRequired
        ? ApprovalGate(
            agentId: event.agentId ?? 'unknown-agent',
            sequence: event.sequence,
          )
        : null;
    _state = _state.copyWith(
      mission: mission,
      lastEventSequence: event.sequence > _state.lastEventSequence
          ? event.sequence
          : _state.lastEventSequence,
      hasEventGap: _state.hasEventGap || gap,
      pendingApproval: approval,
      clearApproval:
          event.type == MissionRuntimeEventType.resumed ||
          event.type == MissionRuntimeEventType.cancelled,
    );
    notifyListeners();
  }

  MissionStatus? _statusForEvent(MissionRuntimeEventType type) =>
      switch (type) {
        MissionRuntimeEventType.queued => MissionStatus.queued,
        MissionRuntimeEventType.running ||
        MissionRuntimeEventType.resumed => MissionStatus.running,
        MissionRuntimeEventType.approvalRequired =>
          MissionStatus.awaitingApproval,
        MissionRuntimeEventType.succeeded => MissionStatus.succeeded,
        MissionRuntimeEventType.failed => MissionStatus.failed,
        MissionRuntimeEventType.cancelled => MissionStatus.cancelled,
      };

  void _update(MissionConfiguration draft) {
    final estimated = draft.agentCount * 120000;
    _state = _state.copyWith(
      draft: draft,
      costPreview: CostPreview(
        estimatedMicros: estimated,
        reservedMicros: estimated,
        currency: 'USD',
      ),
      clearFailure: true,
    );
    _submission = null;
    _submissionKey = null;
    notifyListeners();
  }
}
