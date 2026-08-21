import '../../../core/api/generated/contracts.dart';

enum ReasoningProfile { auto, fast, balanced, deep, maximum }

extension ReasoningProfileContract on ReasoningProfile {
  bool get isAuto => this == ReasoningProfile.auto;

  String get label => switch (this) {
    ReasoningProfile.auto => 'Auto',
    ReasoningProfile.fast => 'Fast',
    ReasoningProfile.balanced => 'Balanced',
    ReasoningProfile.deep => 'Deep',
    ReasoningProfile.maximum => 'Maximum',
  };

  UniversalReasoningLevel? get universalLevel => switch (this) {
    ReasoningProfile.auto => null,
    ReasoningProfile.fast => UniversalReasoningLevel.fast,
    ReasoningProfile.balanced => UniversalReasoningLevel.balanced,
    ReasoningProfile.deep => UniversalReasoningLevel.deep,
    ReasoningProfile.maximum => UniversalReasoningLevel.max,
  };

  String? get wireName => switch (this) {
    ReasoningProfile.auto => null,
    ReasoningProfile.fast => 'fast',
    ReasoningProfile.balanced => 'balanced',
    ReasoningProfile.deep => 'deep',
    ReasoningProfile.maximum => 'max',
  };
}

final class ReasoningChoice {
  ReasoningChoice({
    required this.profile,
    required this.enabled,
    required this.requiresCostWarning,
    required Map<String, Object?> providerParameters,
    this.disabledReason,
  }) : providerParameters = Map<String, Object?>.unmodifiable(
         providerParameters,
       );

  final ReasoningProfile profile;
  final bool enabled;
  final bool requiresCostWarning;
  final Map<String, Object?> providerParameters;
  final String? disabledReason;
}

final class ReasoningResolver {
  const ReasoningResolver();

  List<ReasoningChoice> choicesFor(ModelCapabilityDto capability) {
    final expensiveLevels =
        switch (capability.extensions['expensiveReasoningLevels']) {
          final List<Object?> values => values.whereType<String>().toSet(),
          _ => const <String>{},
        };

    return ReasoningProfile.values
        .map((profile) {
          final level = profile.universalLevel;
          if (level == null) {
            return ReasoningChoice(
              profile: profile,
              enabled: true,
              requiresCostWarning: false,
              providerParameters: const <String, Object?>{},
            );
          }

          final supported = capability.reasoning.supportedUniversalLevels
              .contains(level);
          final parameters = capability.reasoning.providerParameters[level];
          final enabled = supported && parameters != null;
          return ReasoningChoice(
            profile: profile,
            enabled: enabled,
            requiresCostWarning: expensiveLevels.contains(profile.wireName),
            providerParameters: enabled
                ? Map<String, Object?>.from(parameters)
                : const <String, Object?>{},
            disabledReason: enabled
                ? null
                : 'Unsupported by ${capability.exactModelId}; policy '
                      '${capability.reasoning.unsupportedPolicy.name}.',
          );
        })
        .toList(growable: false);
  }
}
