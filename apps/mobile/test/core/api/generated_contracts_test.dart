import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/core/api/generated/contracts.dart';

void main() {
  test('mission DTO round-trips stable wire names', () {
    final source = <String, Object?>{
      'id': '3de4ae3b-b0de-4e1c-a70a-30c6823d6f13',
      'ownerId': '782458e7-6fe5-4b08-a47e-a3823738b581',
      'title': 'Verify release',
      'status': 'awaiting_approval',
      'createdAt': '2026-08-20T20:00:00.000Z',
      'updatedAt': '2026-08-20T20:01:00.000Z',
      'lastEventSequence': 4,
      'budgetLimitMicros': 2500000,
      'concurrencyLimit': 8,
    };

    final dto = MissionDto.fromJson(source);

    expect(dto.status, MissionStatus.awaitingApproval);
    expect(dto.toJson(), source);
  });

  test('exact model capability preserves only explicit extension maps', () {
    final source = <String, Object?>{
      'exactModelId': 'provider/model-version',
      'provider': 'openai_compatible',
      'supportsStreaming': true,
      'contextWindowTokens': 128000,
      'reasoning': <String, Object?>{
        'supportedUniversalLevels': <Object?>['fast', 'deep'],
        'mappings': <String, Object?>{
          'fast': <String, Object?>{
            'providerParameters': <String, Object?>{'effort': 'low'},
          },
          'deep': <String, Object?>{
            'providerParameters': <String, Object?>{'effort': 'high'},
          },
        },
        'unsupportedPolicy': 'reject',
      },
      'extensions': <String, Object?>{'vendorFeature': true},
    };

    final dto = ModelCapabilityDto.fromJson(source);

    expect(dto.provider, ProviderKind.openaiCompatible);
    expect(dto.reasoning.unsupportedPolicy, UnsupportedReasoningPolicy.reject);
    expect(dto.toJson(), source);
  });

  test('unknown provider capability fails closed', () {
    expect(
      () => ModelCapabilityDto.fromJson(<String, Object?>{
        'exactModelId': 'unknown/model',
        'provider': 'unknown',
        'supportsStreaming': false,
        'reasoning': <String, Object?>{
          'supportedUniversalLevels': <Object?>[],
          'mappings': <String, Object?>{},
          'unsupportedPolicy': 'reject',
        },
      }),
      throwsFormatException,
    );
  });
}
