import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

part 'tts_service.g.dart';

@riverpod
TtsService ttsService(TtsServiceRef ref) {
  return TtsService();
}

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentUtterance = '';
  
  StreamController<bool>? _speakingController;
  StreamController<String>? _utteranceController;
  
  Stream<bool> get isSpeakingStream => _speakingController?.stream ?? const Stream.empty();
  Stream<String> get utteranceStream => _utteranceController?.stream ?? const Stream.empty();
  bool get isSpeaking => _isSpeaking;
  String get currentUtterance => _currentUtterance;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Permission.microphone.request();
    
    _speakingController = StreamController<bool>.broadcast();
    _utteranceController = StreamController<String>.broadcast();
    
    _tts.setStartHandler(() {
      _isSpeaking = true;
      _speakingController?.add(true);
    });
    
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _currentUtterance = '';
      _speakingController?.add(false);
      _utteranceController?.add('');
    });
    
    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      _speakingController?.add(false);
      _utteranceController?.add('');
      print('TTS Error: $msg');
    });
    
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(1.0);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    
    final voices = await _tts.getVoices;
    if (voices != null) {
      final neuralVoice = voices.cast<Map<dynamic, dynamic>>().firstWhere(
        (v) => (v['name'] as String).toLowerCase().contains('neural') ||
               (v['name'] as String).toLowerCase().contains('premium') ||
               (v['name'] as String).toLowerCase().contains('enhanced'),
        orElse: () => voices.first,
      );
      await _tts.setVoice(neuralVoice);
    }
    
    _isInitialized = true;
  }
  
  Future<void> speak(String text, {String voiceName = 'Grok-CyberVoice'}) async {
    if (!_isInitialized) await initialize();
    if (text.trim().isEmpty) return;
    
    _currentUtterance = text.length > 120 ? '${text.substring(0, 120)}...' : text;
    _utteranceController?.add(_currentUtterance);
    
    final cleanText = text
        .replaceAll(RegExp(r'[#*`_{}\[\]\\]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    await _tts.speak(cleanText);
  }
  
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    _currentUtterance = '';
    _speakingController?.add(false);
    _utteranceController?.add('');
  }
  
  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }
  
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }
  
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }
  
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }
  
  void dispose() {
    _tts.stop();
    _speakingController?.close();
    _utteranceController?.close();
  }
}
