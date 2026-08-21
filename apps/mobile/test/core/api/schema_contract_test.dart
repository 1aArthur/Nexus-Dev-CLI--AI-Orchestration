import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readContract(String name) {
  final file = File('../../packages/api_schema/$name');
  expect(file.existsSync(), isTrue, reason: 'Missing contract: $name');
  return file.readAsStringSync();
}

void main() {
  test('OpenAPI mutations and shared DTOs expose security invariants', () {
    final openApi = _readContract('openapi.yaml');

    for (final requiredToken in <String>[
      'openapi: 3.1.0',
      'Idempotency-Key',
      'format: uuid',
      'traceId',
      'MissionDto',
      'MissionEventDto',
      'ExecutionTargetDto',
      'UsageRecordDto',
      'ModelCapabilityDto',
      'ApiErrorDto',
    ]) {
      expect(openApi, contains(requiredToken));
    }
  });

  test('event schema requires ordered mission events and provenance', () {
    final schema =
        jsonDecode(_readContract('events.schema.json')) as Map<String, dynamic>;
    final properties = schema['properties'] as Map<String, dynamic>;
    final required = (schema['required'] as List<dynamic>).cast<String>();

    expect(schema[r'$schema'], contains('2020-12'));
    expect(
      required,
      containsAll(<String>[
        'eventId',
        'missionId',
        'sequence',
        'traceId',
        'type',
        'occurredAt',
        'payload',
      ]),
    );
    expect(properties['sequence'], containsPair('minimum', 1));
    expect(schema, contains('oneOf'));
  });

  test('model capability schema maps universal reasoning by exact model', () {
    final schema =
        jsonDecode(_readContract('model-capabilities.schema.json'))
            as Map<String, dynamic>;
    final required = (schema['required'] as List<dynamic>).cast<String>();

    expect(
      required,
      containsAll(<String>[
        'exactModelId',
        'provider',
        'reasoning',
        'supportsStreaming',
      ]),
    );
    expect(jsonEncode(schema), contains('providerParameters'));
    expect(jsonEncode(schema), contains('unsupportedPolicy'));
  });

  test('execution targets declare kind, capabilities, and approval mode', () {
    final schema =
        jsonDecode(_readContract('execution-targets.schema.json'))
            as Map<String, dynamic>;
    final encoded = jsonEncode(schema);

    for (final requiredToken in <String>[
      'device',
      'github_actions',
      'codespaces',
      'ssh_worker',
      'capabilities',
      'approvalMode',
    ]) {
      expect(encoded, contains(requiredToken));
    }
  });
}
