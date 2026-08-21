import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/voice/application/voice_controller.dart';
import 'package:nexus_mobile/features/voice/data/xai_realtime_socket.dart';

void main() {
  final now = DateTime.utc(2026, 8, 20, 12);

  test('expired client secrets are replaced before connecting', () async {
    final broker = _QueueBroker(<RealtimeClientSecret>[
      RealtimeClientSecret(
        value: 'expired-client-secret',
        expiresAt: now.subtract(const Duration(seconds: 1)),
      ),
      RealtimeClientSecret(
        value: 'fresh-client-secret',
        expiresAt: now.add(const Duration(minutes: 5)),
      ),
    ]);
    final transport = _RecordingTransport();
    final controller = VoiceController(
      broker: broker,
      transport: transport,
      store: _RecordingStore(),
      clock: () => now,
    );

    await controller.start();

    expect(broker.issueCount, 2);
    expect(transport.connectedTokens, <String>['fresh-client-secret']);
    expect(transport.connectedUris.single.host, 'api.x.ai');
  });

  test('discard clears memory and never persists without explicit save', () async {
    final store = _RecordingStore();
    final transport = _RecordingTransport();
    final controller = VoiceController(
      broker: _QueueBroker(<RealtimeClientSecret>[
        RealtimeClientSecret(
          value: 'ephemeral',
          expiresAt: now.add(const Duration(minutes: 5)),
        ),
      ]),
      transport: transport,
      store: store,
      clock: () => now,
    );
    controller.handleEvent(<String, Object?>{
      'type': 'conversation.item.input_audio_transcription.updated',
      'sequence': 1,
      'transcript': 'Não persista automaticamente',
    });
    controller.handleEvent(<String, Object?>{
      'type': 'response.output_audio.delta',
      'sequence': 2,
      'delta': 'cGNt',
    });

    await controller.discard();

    expect(controller.state.inputTranscript, isEmpty);
    expect(controller.state.outputTranscript, isEmpty);
    expect(controller.state.audioChunks, isEmpty);
    expect(store.saved, isEmpty);
    expect(
      transport.sentEvents,
      contains(<String, Object?>{'type': 'input_audio_buffer.clear'}),
    );
  });

  test('save persists transcripts only after explicit user action', () async {
    final store = _RecordingStore();
    final controller = VoiceController(
      broker: _QueueBroker(const <RealtimeClientSecret>[]),
      transport: _RecordingTransport(),
      store: store,
      clock: () => now,
    );
    controller.handleEvent(<String, Object?>{
      'type': 'conversation.item.input_audio_transcription.updated',
      'sequence': 1,
      'transcript': 'Criar missão segura',
    });
    controller.handleEvent(<String, Object?>{
      'type': 'response.output_audio_transcript.delta',
      'sequence': 2,
      'delta': 'Confirmado',
    });

    expect(store.saved, isEmpty);
    await controller.save();

    expect(store.saved, <({String input, String output})>[
      (input: 'Criar missão segura', output: 'Confirmado'),
    ]);
    expect(controller.state.saved, isTrue);
  });
}

final class _QueueBroker implements VoiceSessionBroker {
  _QueueBroker(this.secrets);

  final List<RealtimeClientSecret> secrets;
  int issueCount = 0;

  @override
  Future<RealtimeClientSecret> issueSecret() async {
    final secret = secrets[issueCount];
    issueCount += 1;
    return secret;
  }
}

final class _RecordingTransport implements XaiRealtimeTransport {
  final StreamController<Map<String, Object?>> _events =
      StreamController<Map<String, Object?>>.broadcast();
  final List<String> connectedTokens = <String>[];
  final List<Uri> connectedUris = <Uri>[];
  final List<Map<String, Object?>> sentEvents = <Map<String, Object?>>[];

  @override
  Stream<Map<String, Object?>> get events => _events.stream;

  @override
  Future<void> close() async {}

  @override
  Future<void> connect({required Uri uri, required String token}) async {
    connectedUris.add(uri);
    connectedTokens.add(token);
  }

  @override
  Future<void> sendJson(Map<String, Object?> event) async {
    sentEvents.add(event);
  }
}

final class _RecordingStore implements VoiceDraftStore {
  final List<({String input, String output})> saved =
      <({String input, String output})>[];

  @override
  Future<void> save({required String input, required String output}) async {
    saved.add((input: input, output: output));
  }
}
