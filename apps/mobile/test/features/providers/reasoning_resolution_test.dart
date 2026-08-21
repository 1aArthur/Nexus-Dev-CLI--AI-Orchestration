import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/core/api/generated/contracts.dart';
import 'package:nexus_mobile/features/providers/application/provider_controller.dart';
import 'package:nexus_mobile/features/providers/domain/reasoning_profile.dart';

void main() {
  // Catches universal reasoning controls that silently send unsupported or
  // guessed provider parameters after an exact-model capability change.
  test('disables unsupported levels and previews exact native parameters', () {
    final capability = ModelCapabilityDto(
      exactModelId: 'provider/exact-snapshot',
      provider: ProviderKind.anthropic,
      supportsStreaming: true,
      reasoning: const ReasoningCapabilityDto(
        supportedUniversalLevels: <UniversalReasoningLevel>[
          UniversalReasoningLevel.fast,
          UniversalReasoningLevel.balanced,
          UniversalReasoningLevel.deep,
        ],
        providerParameters: <UniversalReasoningLevel, JsonMap>{
          UniversalReasoningLevel.fast: <String, Object?>{
            'thinking': 'adaptive',
            'effort': 'low',
          },
          UniversalReasoningLevel.balanced: <String, Object?>{
            'thinking': 'adaptive',
            'effort': 'medium',
          },
          UniversalReasoningLevel.deep: <String, Object?>{
            'thinking': 'adaptive',
            'effort': 'high',
          },
        },
        unsupportedPolicy: UnsupportedReasoningPolicy.reject,
      ),
      extensions: const <String, Object?>{
        'expensiveReasoningLevels': <Object?>['deep'],
      },
    );

    final choices = const ReasoningResolver().choicesFor(capability);

    expect(choices, hasLength(5));
    expect(
      choices.singleWhere((choice) => choice.profile.isAuto).enabled,
      true,
    );
    expect(
      choices
          .singleWhere((choice) => choice.profile == ReasoningProfile.deep)
          .providerParameters,
      <String, Object?>{'thinking': 'adaptive', 'effort': 'high'},
    );
    expect(
      choices
          .singleWhere((choice) => choice.profile == ReasoningProfile.deep)
          .requiresCostWarning,
      true,
    );
    expect(
      choices
          .singleWhere((choice) => choice.profile == ReasoningProfile.maximum)
          .enabled,
      false,
    );
  });

  // Catches compatible endpoints that could downgrade TLS or directly target
  // loopback/private infrastructure before gateway SSRF enforcement.
  test('compatible endpoint policy fails closed before server validation', () {
    const policy = ProviderEndpointPolicy();

    expect(
      policy.validate(Uri.parse('https://api.example.com/v1')).allowed,
      true,
    );
    for (final endpoint in <String>[
      'http://api.example.com/v1',
      'https://localhost/v1',
      'https://127.0.0.1/v1',
      'https://2130706433/v1',
      'https://999.1.1.1/v1',
      'https://10.20.30.40/v1',
      'https://[::1]/v1',
      'https://[fd00::1]/v1',
      'https://user:pass@api.example.com/v1',
      'https://api.example.com/v1#fragment',
    ]) {
      expect(
        policy.validate(Uri.parse(endpoint)).allowed,
        false,
        reason: endpoint,
      );
    }
    expect(policy.gatewayEnforcementNotice, contains('DNS'));
    expect(policy.gatewayEnforcementNotice, contains('allowlist'));
  });
}
