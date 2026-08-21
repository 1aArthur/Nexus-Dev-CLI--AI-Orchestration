import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/xai_realtime_socket.dart';
import '../domain/voice_state.dart';

final class RealtimeClientSecret {
  const RealtimeClientSecret({required this.value, required this.expiresAt});

  final String value;
  final DateTime expiresAt;

  bool isUsableAt(DateTime now, {Duration skew = const Duration(seconds: 15)}) {
    return expiresAt.isAfter(now.add(skew));
  }
}

abstract interface class VoiceSessionBroker {
  Future<RealtimeClientSecret> issueSecret();
}

abstract interface class VoiceDraftStore {
  Future<void> save({required String input, required String output});
}

final class VoiceMissionDraft {
  const VoiceMissionDraft({required this.title, required this.prompt});

  final String title;
  final String prompt;
}

final class VoiceController extends ChangeNotifier {
  VoiceController({
    required this.broker,
    required this.transport,
    required this.store,
    DateTime Function()? clock,
    this.maximumAudioChunks = 32,
  }) : clock = clock ?? DateTime.now,
       _reducer = VoiceTranscriptReducer(
         maximumAudioChunks: maximumAudioChunks,
       );

  static final Uri realtimeUri = Uri.parse(
    'wss://api.x.ai/v1/realtime?model=grok-voice-latest',
  );

  final VoiceSessionBroker broker;
  final XaiRealtimeTransport transport;
  final VoiceDraftStore store;
  final DateTime Function() clock;
  final int maximumAudioChunks;
  final VoiceTranscriptReducer _reducer;
  StreamSubscription<Map<String, Object?>>? _eventSubscription;
  VoiceState _state = const VoiceState();

  VoiceState get state => _state;

  Future<void> start() async {
    try {
      _setPhase(VoicePhase.requestingSecret);
      var secret = await broker.issueSecret();
      if (!secret.isUsableAt(clock())) {
        secret = await broker.issueSecret();
      }
      if (!secret.isUsableAt(clock())) {
        throw StateError('The gateway returned an expired client secret');
      }

      _setPhase(VoicePhase.connecting);
      await _eventSubscription?.cancel();
      await transport.connect(uri: realtimeUri, token: secret.value);
      _eventSubscription = transport.events.listen(
        handleEvent,
        onError: _handleTransportError,
      );
      await transport.sendJson(_sessionConfiguration);
      _setPhase(VoicePhase.listening);
    } on Object {
      _setPhase(VoicePhase.error);
      rethrow;
    }
  }

  void handleEvent(Map<String, Object?> event) {
    _state = _reducer.apply(_state, VoiceRealtimeEvent.fromJson(event));
    notifyListeners();
  }

  Future<void> sendPcm(Uint8List pcm) {
    return transport.sendJson(<String, Object?>{
      'type': 'input_audio_buffer.append',
      'audio': base64Encode(pcm),
    });
  }

  Future<void> pause() async {
    _setPhase(VoicePhase.paused);
  }

  Future<void> discard() async {
    try {
      await transport.sendJson(<String, Object?>{
        'type': 'input_audio_buffer.clear',
      });
    } on StateError {
      // A disconnected session can still be discarded locally.
    }
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    await transport.close();
    _state = const VoiceState();
    notifyListeners();
  }

  Future<void> save() async {
    await store.save(
      input: _state.inputTranscript,
      output: _state.outputTranscript,
    );
    _state = _state.copyWith(saved: true);
    notifyListeners();
  }

  VoiceMissionDraft createMissionDraft() {
    return VoiceMissionDraft(
      title: 'Voice mission',
      prompt: <String>[
        _state.inputTranscript,
        _state.outputTranscript,
      ].where((value) => value.isNotEmpty).join('\n\n'),
    );
  }

  Map<String, Object?> get _sessionConfiguration => <String, Object?>{
    'type': 'session.update',
    'session': <String, Object?>{
      'voice': 'eve',
      'instructions':
          'You are the voice interface for a secure agent orchestrator. '
          'Confirm intent before proposing state-changing actions.',
      'turn_detection': <String, Object?>{'type': 'server_vad'},
      'audio': <String, Object?>{
        'input': <String, Object?>{
          'format': <String, Object?>{'type': 'audio/pcm', 'rate': 24000},
          'transport': 'json',
          'transcription': <String, Object?>{
            'model': 'grok-transcribe',
            'language_hint': 'pt-BR',
          },
        },
        'output': <String, Object?>{
          'format': <String, Object?>{'type': 'audio/pcm', 'rate': 24000},
          'transport': 'json',
        },
      },
    },
  };

  void _setPhase(VoicePhase phase) {
    _state = _state.copyWith(phase: phase);
    notifyListeners();
  }

  void _handleTransportError(Object error, StackTrace stackTrace) {
    _setPhase(VoicePhase.error);
  }

  @override
  void dispose() {
    unawaited(_eventSubscription?.cancel());
    unawaited(transport.close());
    super.dispose();
  }
}
