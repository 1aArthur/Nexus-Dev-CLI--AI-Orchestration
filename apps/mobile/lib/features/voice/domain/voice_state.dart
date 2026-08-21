enum VoicePhase {
  idle,
  requestingSecret,
  connecting,
  listening,
  paused,
  responding,
  error,
}

final class VoiceRealtimeEvent {
  const VoiceRealtimeEvent({
    required this.type,
    this.sequence,
    this.transcript,
    this.delta,
    this.audioBase64,
  });

  factory VoiceRealtimeEvent.fromJson(Map<String, Object?> json) {
    return VoiceRealtimeEvent(
      type: json['type'] as String? ?? 'unknown',
      sequence: json['sequence'] as int?,
      transcript: json['transcript'] as String?,
      delta: json['delta'] as String?,
      audioBase64: json['delta'] as String?,
    );
  }

  final String type;
  final int? sequence;
  final String? transcript;
  final String? delta;
  final String? audioBase64;
}

final class VoiceState {
  const VoiceState({
    this.phase = VoicePhase.idle,
    this.inputTranscript = '',
    this.outputTranscript = '',
    this.audioChunks = const <String>[],
    this.handledSequences = const <int>{},
    this.unknownEventTypes = const <String>[],
    this.saved = false,
  });

  final VoicePhase phase;
  final String inputTranscript;
  final String outputTranscript;
  final List<String> audioChunks;
  final Set<int> handledSequences;
  final List<String> unknownEventTypes;
  final bool saved;

  VoiceState copyWith({
    VoicePhase? phase,
    String? inputTranscript,
    String? outputTranscript,
    List<String>? audioChunks,
    Set<int>? handledSequences,
    List<String>? unknownEventTypes,
    bool? saved,
  }) {
    return VoiceState(
      phase: phase ?? this.phase,
      inputTranscript: inputTranscript ?? this.inputTranscript,
      outputTranscript: outputTranscript ?? this.outputTranscript,
      audioChunks: audioChunks ?? this.audioChunks,
      handledSequences: handledSequences ?? this.handledSequences,
      unknownEventTypes: unknownEventTypes ?? this.unknownEventTypes,
      saved: saved ?? this.saved,
    );
  }
}

final class VoiceTranscriptReducer {
  const VoiceTranscriptReducer({this.maximumAudioChunks = 32});

  final int maximumAudioChunks;

  VoiceState apply(VoiceState state, VoiceRealtimeEvent event) {
    final sequence = event.sequence;
    if (sequence != null && state.handledSequences.contains(sequence)) {
      return state;
    }
    final handled = sequence == null
        ? state.handledSequences
        : Set<int>.unmodifiable(<int>{...state.handledSequences, sequence});

    switch (event.type) {
      case 'conversation.item.input_audio_transcription.updated':
        return state.copyWith(
          inputTranscript: event.transcript ?? state.inputTranscript,
          handledSequences: handled,
          saved: false,
        );
      case 'response.output_audio_transcript.delta':
        return state.copyWith(
          phase: VoicePhase.responding,
          outputTranscript: '${state.outputTranscript}${event.delta ?? ''}',
          handledSequences: handled,
          saved: false,
        );
      case 'response.output_audio.delta':
      case 'response.audio.delta':
        final audio = event.audioBase64;
        if (audio == null || audio.isEmpty) {
          return state.copyWith(handledSequences: handled);
        }
        final chunks = <String>[...state.audioChunks, audio];
        final retained = chunks.length > maximumAudioChunks
            ? chunks.skip(chunks.length - maximumAudioChunks)
            : chunks;
        return state.copyWith(
          phase: VoicePhase.responding,
          audioChunks: List<String>.unmodifiable(retained),
          handledSequences: handled,
        );
      case 'input_audio_buffer.speech_started':
      case 'input_audio_buffer.speech_stopped':
      case 'session.created':
      case 'session.updated':
        return state.copyWith(
          phase: VoicePhase.listening,
          handledSequences: handled,
        );
      case 'response.created':
        return state.copyWith(
          phase: VoicePhase.responding,
          handledSequences: handled,
        );
      case 'response.done':
        return state.copyWith(
          phase: VoicePhase.listening,
          handledSequences: handled,
        );
      case 'error':
        return state.copyWith(
          phase: VoicePhase.error,
          handledSequences: handled,
        );
      default:
        if (state.unknownEventTypes.contains(event.type)) return state;
        final eventTypes = <String>[...state.unknownEventTypes, event.type];
        return state.copyWith(
          handledSequences: handled,
          unknownEventTypes: List<String>.unmodifiable(
            eventTypes.length > 20
                ? eventTypes.skip(eventTypes.length - 20)
                : eventTypes,
          ),
        );
    }
  }
}
