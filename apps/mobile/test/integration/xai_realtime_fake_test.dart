import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/voice/application/voice_controller.dart';
import 'package:nexus_mobile/features/voice/data/xai_realtime_socket.dart';

void main() {
  test('fake realtime session configures PCM, streams, and discards', () async {
    final events = StreamController<Map<String, Object?>>();
    final transport = _FakeTransport(events.stream);
    final controller = VoiceController(
      broker: _FreshBroker(),
      transport: transport,
      store: _NoopStore(),
      clock: () => DateTime.utc(2026, 8, 20),
      maximumAudioChunks: 2,
    );

    await controller.start();
    final session = transport.sent.single['session']! as Map<String, Object?>;
    final audio = session['audio']! as Map<String, Object?>;
    final input = audio['input']! as Map<String, Object?>;
    final transcription = input['transcription']! as Map<String, Object?>;
    expect(transcription['language_hint'], 'pt-BR');
    expect(session.toString(), isNot(contains('XAI_API_KEY')));

    await controller.sendPcm(Uint8List.fromList(<int>[1, 2, 3]));
    expect(transport.sent.last, <String, Object?>{
      'type': 'input_audio_buffer.append',
      'audio': base64Encode(<int>[1, 2, 3]),
    });

    events.add(<String, Object?>{
      'type': 'conversation.item.input_audio_transcription.updated',
      'sequence': 1,
      'transcript': 'Execute a revisão',
    });
    events.add(<String, Object?>{
      'type': 'response.output_audio_transcript.delta',
      'sequence': 2,
      'delta': 'Vou criar uma missão.',
    });
    await Future<void>.delayed(Duration.zero);

    final draft = controller.createMissionDraft();
    expect(draft.prompt, contains('Execute a revisão'));
    expect(draft.prompt, contains('Vou criar uma missão.'));

    await controller.discard();
    expect(transport.closed, isTrue);
    expect(controller.state.inputTranscript, isEmpty);
    await events.close();
  });
}

final class _FreshBroker implements VoiceSessionBroker {
  @override
  Future<RealtimeClientSecret> issueSecret() async => RealtimeClientSecret(
    value: 'short-lived-client-secret',
    expiresAt: DateTime.utc(2026, 8, 20, 1),
  );
}

final class _FakeTransport implements XaiRealtimeTransport {
  _FakeTransport(this.events);

  @override
  final Stream<Map<String, Object?>> events;
  final List<Map<String, Object?>> sent = <Map<String, Object?>>[];
  bool closed = false;

  @override
  Future<void> close() async => closed = true;

  @override
  Future<void> connect({required Uri uri, required String token}) async {
    expect(uri.scheme, 'wss');
    expect(token, 'short-lived-client-secret');
  }

  @override
  Future<void> sendJson(Map<String, Object?> event) async => sent.add(event);
}

final class _NoopStore implements VoiceDraftStore {
  @override
  Future<void> save({required String input, required String output}) async {}
}
