// Generated from packages/api_schema.
// schema-digest: 7b8d22ddd8c3d1e81cd42252c70c9e9472bf2d7ee290c548cbeba89fcd296a61
// Do not add business logic to this file.

typedef JsonMap = Map<String, Object?>;

enum MissionStatus {
  draft,
  queued,
  running,
  awaitingApproval,
  succeeded,
  failed,
  cancelled,
}

enum ExecutionTargetKind { device, githubActions, codespaces, sshWorker }

enum ExecutionTargetStatus { available, unavailable, requiresAuth, disabled }

enum ApprovalMode { alwaysAsk, policy, neverForSafeNative }

enum UsageProvenance { providerReported, estimated, adjusted }

enum ProviderKind {
  openai,
  anthropic,
  xai,
  openaiCompatible,
  anthropicCompatible,
}

enum UniversalReasoningLevel { fast, balanced, deep, max }

enum UnsupportedReasoningPolicy { reject, clamp, omit }

T _wireEnum<T>(String value, Map<String, T> values, String field) {
  final parsed = values[value];
  if (parsed == null) {
    throw FormatException('Unsupported $field: $value');
  }
  return parsed;
}

String _string(JsonMap json, String field) {
  final value = json[field];
  if (value is! String || value.isEmpty) {
    throw FormatException('$field must be a non-empty string');
  }
  return value;
}

int _integer(JsonMap json, String field) {
  final value = json[field];
  if (value is! int) {
    throw FormatException('$field must be an integer');
  }
  return value;
}

bool _boolean(JsonMap json, String field) {
  final value = json[field];
  if (value is! bool) {
    throw FormatException('$field must be a boolean');
  }
  return value;
}

JsonMap _map(JsonMap json, String field) {
  final value = json[field];
  if (value is! Map) {
    throw FormatException('$field must be an object');
  }
  return JsonMap.from(value);
}

const _missionStatuses = <String, MissionStatus>{
  'draft': MissionStatus.draft,
  'queued': MissionStatus.queued,
  'running': MissionStatus.running,
  'awaiting_approval': MissionStatus.awaitingApproval,
  'succeeded': MissionStatus.succeeded,
  'failed': MissionStatus.failed,
  'cancelled': MissionStatus.cancelled,
};

const _targetKinds = <String, ExecutionTargetKind>{
  'device': ExecutionTargetKind.device,
  'github_actions': ExecutionTargetKind.githubActions,
  'codespaces': ExecutionTargetKind.codespaces,
  'ssh_worker': ExecutionTargetKind.sshWorker,
};

const _targetStatuses = <String, ExecutionTargetStatus>{
  'available': ExecutionTargetStatus.available,
  'unavailable': ExecutionTargetStatus.unavailable,
  'requires_auth': ExecutionTargetStatus.requiresAuth,
  'disabled': ExecutionTargetStatus.disabled,
};

const _approvalModes = <String, ApprovalMode>{
  'always_ask': ApprovalMode.alwaysAsk,
  'policy': ApprovalMode.policy,
  'never_for_safe_native': ApprovalMode.neverForSafeNative,
};

const _usageProvenance = <String, UsageProvenance>{
  'provider_reported': UsageProvenance.providerReported,
  'estimated': UsageProvenance.estimated,
  'adjusted': UsageProvenance.adjusted,
};

const _providerKinds = <String, ProviderKind>{
  'openai': ProviderKind.openai,
  'anthropic': ProviderKind.anthropic,
  'xai': ProviderKind.xai,
  'openai_compatible': ProviderKind.openaiCompatible,
  'anthropic_compatible': ProviderKind.anthropicCompatible,
};

const _reasoningLevels = <String, UniversalReasoningLevel>{
  'fast': UniversalReasoningLevel.fast,
  'balanced': UniversalReasoningLevel.balanced,
  'deep': UniversalReasoningLevel.deep,
  'max': UniversalReasoningLevel.max,
};

const _unsupportedPolicies = <String, UnsupportedReasoningPolicy>{
  'reject': UnsupportedReasoningPolicy.reject,
  'clamp': UnsupportedReasoningPolicy.clamp,
  'omit': UnsupportedReasoningPolicy.omit,
};

String _wireName(Enum value) {
  return switch (value) {
    MissionStatus.awaitingApproval => 'awaiting_approval',
    ExecutionTargetKind.githubActions => 'github_actions',
    ExecutionTargetKind.sshWorker => 'ssh_worker',
    ExecutionTargetStatus.requiresAuth => 'requires_auth',
    ApprovalMode.alwaysAsk => 'always_ask',
    ApprovalMode.neverForSafeNative => 'never_for_safe_native',
    UsageProvenance.providerReported => 'provider_reported',
    ProviderKind.openaiCompatible => 'openai_compatible',
    ProviderKind.anthropicCompatible => 'anthropic_compatible',
    _ => value.name,
  };
}

final class MissionDto {
  const MissionDto({
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

  factory MissionDto.fromJson(JsonMap json) => MissionDto(
    id: _string(json, 'id'),
    ownerId: _string(json, 'ownerId'),
    title: _string(json, 'title'),
    status: _wireEnum(
      _string(json, 'status'),
      _missionStatuses,
      'mission status',
    ),
    createdAt: DateTime.parse(_string(json, 'createdAt')),
    updatedAt: DateTime.parse(_string(json, 'updatedAt')),
    lastEventSequence: _integer(json, 'lastEventSequence'),
    budgetLimitMicros: json['budgetLimitMicros'] as int?,
    concurrencyLimit: json['concurrencyLimit'] as int?,
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

  JsonMap toJson() => <String, Object?>{
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'status': _wireName(status),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'lastEventSequence': lastEventSequence,
    if (budgetLimitMicros != null) 'budgetLimitMicros': budgetLimitMicros,
    if (concurrencyLimit != null) 'concurrencyLimit': concurrencyLimit,
  };
}

final class MissionEventDto {
  const MissionEventDto({
    required this.eventId,
    required this.missionId,
    required this.sequence,
    required this.traceId,
    required this.type,
    required this.occurredAt,
    required this.payload,
  });

  factory MissionEventDto.fromJson(JsonMap json) => MissionEventDto(
    eventId: _string(json, 'eventId'),
    missionId: _string(json, 'missionId'),
    sequence: _integer(json, 'sequence'),
    traceId: _string(json, 'traceId'),
    type: _string(json, 'type'),
    occurredAt: DateTime.parse(_string(json, 'occurredAt')),
    payload: _map(json, 'payload'),
  );

  final String eventId;
  final String missionId;
  final int sequence;
  final String traceId;
  final String type;
  final DateTime occurredAt;
  final JsonMap payload;

  JsonMap toJson() => <String, Object?>{
    'eventId': eventId,
    'missionId': missionId,
    'sequence': sequence,
    'traceId': traceId,
    'type': type,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'payload': payload,
  };
}

final class ExecutionTargetDto {
  const ExecutionTargetDto({
    required this.id,
    required this.displayName,
    required this.kind,
    required this.status,
    required this.capabilities,
    required this.approvalMode,
  });

  factory ExecutionTargetDto.fromJson(JsonMap json) => ExecutionTargetDto(
    id: _string(json, 'id'),
    displayName: _string(json, 'displayName'),
    kind: _wireEnum(_string(json, 'kind'), _targetKinds, 'target kind'),
    status: _wireEnum(
      _string(json, 'status'),
      _targetStatuses,
      'target status',
    ),
    capabilities: (json['capabilities'] as List<Object?>).cast<String>(),
    approvalMode: _wireEnum(
      _string(json, 'approvalMode'),
      _approvalModes,
      'approval mode',
    ),
  );

  final String id;
  final String displayName;
  final ExecutionTargetKind kind;
  final ExecutionTargetStatus status;
  final List<String> capabilities;
  final ApprovalMode approvalMode;

  JsonMap toJson() => <String, Object?>{
    'id': id,
    'displayName': displayName,
    'kind': _wireName(kind),
    'status': _wireName(status),
    'capabilities': capabilities,
    'approvalMode': _wireName(approvalMode),
  };
}

final class UsageRecordDto {
  const UsageRecordDto({
    required this.id,
    required this.missionId,
    required this.provider,
    required this.exactModelId,
    required this.inputTokens,
    required this.outputTokens,
    required this.costMicros,
    required this.currency,
    required this.provenance,
    required this.recordedAt,
    this.cachedInputTokens,
  });

  factory UsageRecordDto.fromJson(JsonMap json) => UsageRecordDto(
    id: _string(json, 'id'),
    missionId: _string(json, 'missionId'),
    provider: _string(json, 'provider'),
    exactModelId: _string(json, 'exactModelId'),
    inputTokens: _integer(json, 'inputTokens'),
    outputTokens: _integer(json, 'outputTokens'),
    cachedInputTokens: json['cachedInputTokens'] as int?,
    costMicros: _integer(json, 'costMicros'),
    currency: _string(json, 'currency'),
    provenance: _wireEnum(
      _string(json, 'provenance'),
      _usageProvenance,
      'usage provenance',
    ),
    recordedAt: DateTime.parse(_string(json, 'recordedAt')),
  );

  final String id;
  final String missionId;
  final String provider;
  final String exactModelId;
  final int inputTokens;
  final int outputTokens;
  final int? cachedInputTokens;
  final int costMicros;
  final String currency;
  final UsageProvenance provenance;
  final DateTime recordedAt;

  JsonMap toJson() => <String, Object?>{
    'id': id,
    'missionId': missionId,
    'provider': provider,
    'exactModelId': exactModelId,
    'inputTokens': inputTokens,
    'outputTokens': outputTokens,
    if (cachedInputTokens != null) 'cachedInputTokens': cachedInputTokens,
    'costMicros': costMicros,
    'currency': currency,
    'provenance': _wireName(provenance),
    'recordedAt': recordedAt.toUtc().toIso8601String(),
  };
}

final class ReasoningCapabilityDto {
  const ReasoningCapabilityDto({
    required this.supportedUniversalLevels,
    required this.providerParameters,
    required this.unsupportedPolicy,
  });

  factory ReasoningCapabilityDto.fromJson(JsonMap json) {
    final rawMappings = _map(json, 'mappings');
    return ReasoningCapabilityDto(
      supportedUniversalLevels:
          (json['supportedUniversalLevels'] as List<Object?>)
              .cast<String>()
              .map(
                (value) =>
                    _wireEnum(value, _reasoningLevels, 'reasoning level'),
              )
              .toList(growable: false),
      providerParameters: rawMappings.map(
        (level, value) => MapEntry(
          _wireEnum(level, _reasoningLevels, 'reasoning mapping'),
          _map(JsonMap.from(value as Map), 'providerParameters'),
        ),
      ),
      unsupportedPolicy: _wireEnum(
        _string(json, 'unsupportedPolicy'),
        _unsupportedPolicies,
        'unsupported reasoning policy',
      ),
    );
  }

  final List<UniversalReasoningLevel> supportedUniversalLevels;
  final Map<UniversalReasoningLevel, JsonMap> providerParameters;
  final UnsupportedReasoningPolicy unsupportedPolicy;

  JsonMap toJson() => <String, Object?>{
    'supportedUniversalLevels': supportedUniversalLevels
        .map(_wireName)
        .toList(growable: false),
    'mappings': providerParameters.map(
      (level, parameters) => MapEntry(_wireName(level), <String, Object?>{
        'providerParameters': parameters,
      }),
    ),
    'unsupportedPolicy': _wireName(unsupportedPolicy),
  };
}

final class ModelCapabilityDto {
  const ModelCapabilityDto({
    required this.exactModelId,
    required this.provider,
    required this.supportsStreaming,
    required this.reasoning,
    this.contextWindowTokens,
    this.extensions = const <String, Object?>{},
  });

  factory ModelCapabilityDto.fromJson(JsonMap json) => ModelCapabilityDto(
    exactModelId: _string(json, 'exactModelId'),
    provider: _wireEnum(_string(json, 'provider'), _providerKinds, 'provider'),
    supportsStreaming: _boolean(json, 'supportsStreaming'),
    reasoning: ReasoningCapabilityDto.fromJson(_map(json, 'reasoning')),
    contextWindowTokens: json['contextWindowTokens'] as int?,
    extensions: json['extensions'] == null
        ? const <String, Object?>{}
        : _map(json, 'extensions'),
  );

  final String exactModelId;
  final ProviderKind provider;
  final bool supportsStreaming;
  final ReasoningCapabilityDto reasoning;
  final int? contextWindowTokens;
  final JsonMap extensions;

  JsonMap toJson() => <String, Object?>{
    'exactModelId': exactModelId,
    'provider': _wireName(provider),
    'supportsStreaming': supportsStreaming,
    'reasoning': reasoning.toJson(),
    if (contextWindowTokens != null) 'contextWindowTokens': contextWindowTokens,
    if (extensions.isNotEmpty) 'extensions': extensions,
  };
}

final class ApiErrorDto {
  const ApiErrorDto({
    required this.code,
    required this.message,
    required this.traceId,
    this.retryable = false,
    this.details = const <String, Object?>{},
  });

  factory ApiErrorDto.fromJson(JsonMap json) => ApiErrorDto(
    code: _string(json, 'code'),
    message: _string(json, 'message'),
    traceId: _string(json, 'traceId'),
    retryable: json['retryable'] as bool? ?? false,
    details: json['details'] == null
        ? const <String, Object?>{}
        : _map(json, 'details'),
  );

  final String code;
  final String message;
  final String traceId;
  final bool retryable;
  final JsonMap details;

  JsonMap toJson() => <String, Object?>{
    'code': code,
    'message': message,
    'traceId': traceId,
    'retryable': retryable,
    if (details.isNotEmpty) 'details': details,
  };
}
