import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/voice/domain/voice_state.dart';

void main() {
  const reducer = VoiceTranscriptReducer();

  test('cumulative input transcription replaces the previous partial', () {
    var state = const VoiceState();
    state = reducer.apply(
      state,
      const VoiceRealtimeEvent(
        type: 'conversation.item.input_audio_transcription.updated',
        sequence: 1,
        transcript: 'Olá',
      ),
    );
    state = reducer.apply(
      state,
      const VoiceRealtimeEvent(
        type: 'conversation.item.input_audio_transcription.updated',
        sequence: 2,
        transcript: 'Olá mundo',
      ),
    );

    expect(state.inputTranscript, 'Olá mundo');
  });

  test('output transcript deltas append exactly once by sequence', () {
    var state = const VoiceState();
    for (final event in const <VoiceRealtimeEvent>[
      VoiceRealtimeEvent(
        type: 'response.output_audio_transcript.delta',
        sequence: 3,
        delta: 'Resposta ',
      ),
      VoiceRealtimeEvent(
        type: 'response.output_audio_transcript.delta',
        sequence: 3,
        delta: 'Resposta ',
      ),
      VoiceRealtimeEvent(
        type: 'response.output_audio_transcript.delta',
        sequence: 4,
        delta: 'final',
      ),
    ]) {
      state = reducer.apply(state, event);
    }

    expect(state.outputTranscript, 'Resposta final');
  });

  test('unknown events retain the type only', () {
    final state = reducer.apply(
      const VoiceState(),
      const VoiceRealtimeEvent(type: 'provider.future_event', delta: 'SECRET'),
    );

    expect(state.unknownEventTypes, <String>['provider.future_event']);
    expect(state.toString(), isNot(contains('SECRET')));
  });
}
