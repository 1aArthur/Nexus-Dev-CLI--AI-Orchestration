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
  }) : clock = clock ?? DateTime.now;

  static final Uri realtimeUri = Uri.parse(
    'wss://api.x.ai/v1/realtime?model=grok-voice-latest',
  );

  final VoiceSessionBroker broker;
  final XaiRealtimeTransport transport;
  final VoiceDraftStore store;
  final DateTime Function() clock;
  final int maximumAudioChunks;
  final VoiceTranscriptReducer _reducer = const VoiceTranscriptReducer();
  VoiceState _state = const VoiceState();

  VoiceState get state => _state;

  Future<void> start() async {
    _state = _state.copyWith(phase: VoicePhase.requestingSecret);
    notifyListeners();
    final secret = await broker.issueSecret();
    _state = _state.copyWith(phase: VoicePhase.connecting);
    notifyListeners();
    await transport.connect(uri: realtimeUri, token: secret.value);
    _state = _state.copyWith(phase: VoicePhase.listening);
    notifyListeners();
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
    _state = _state.copyWith(phase: VoicePhase.paused);
    notifyListeners();
  }

  Future<void> discard() async {}

  Future<void> save() async {}

  VoiceMissionDraft createMissionDraft() {
    return VoiceMissionDraft(
      title: 'Voice mission',
      prompt: <String>[
        _state.inputTranscript,
        _state.outputTranscript,
      ].where((value) => value.isNotEmpty).join('\n\n'),
    );
  }
}
