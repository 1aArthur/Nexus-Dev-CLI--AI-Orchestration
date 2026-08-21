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
  const VoiceTranscriptReducer();

  VoiceState apply(VoiceState state, VoiceRealtimeEvent event) {
    return state;
  }
}
