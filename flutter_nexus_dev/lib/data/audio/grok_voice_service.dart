import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/models.dart';

part 'grok_voice_service.g.dart';

@riverpod
GrokVoiceService grokVoiceService(GrokVoiceServiceRef ref) {
  return GrokVoiceService();
}

class GrokVoiceService {
  WebSocketChannel? _channel;
  StreamController<String>? _transcriptController;
  StreamController<List<int>>? _audioController;
  bool _isConnected = false;
  String _apiKey = '';
  
  Stream<String> get transcriptStream => _transcriptController?.stream ?? const Stream.empty();
  Stream<List<int>> get audioStream => _audioController?.stream ?? const Stream.empty();
  bool get isConnected => _isConnected;
  
  void setApiKey(String key) {
    _apiKey = key;
  }
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    _transcriptController = StreamController<String>.broadcast();
    _audioController = StreamController<List<int>>.broadcast();
    
    try {
      final uri = Uri.parse('wss://api.x.ai/v1/realtime?agent_id=agent_3B5CIJqHTTpwjISg');
      _channel = WebSocketChannel.connect(uri, protocols: ['realtime']);
      
      await _channel!.ready;
      
      _channel!.sink.add(jsonEncode({
        'type': 'auth',
        'api_key': _apiKey,
      }));
      
      _isConnected = true;
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
      
      _sendConversationItem('Hello, Nexus Dev Orchestrator ready for voice input.');
      _sendResponseCreate();
      
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      final event = jsonDecode(message as String);
      
      switch (event['type']) {
        case 'response.output_audio_transcript.delta':
          final delta = event['delta'] as String?;
          if (delta != null && delta.isNotEmpty) {
            _transcriptController?.add(delta);
          }
          break;
        case 'response.output_audio.delta':
          final delta = event['delta'] as String?;
          if (delta != null) {
            final pcm = base64Decode(delta);
            _audioController?.add(pcm);
          }
          break;
        case 'response.done':
          _sendResponseCreate();
          break;
        case 'error':
          print('Grok WebSocket error: ${event['error']}');
          break;
      }
    } catch (e) {
      print('Error parsing Grok message: $e');
    }
  }
  
  void _handleError(Object error) {
    print('Grok WebSocket error: $error');
    _isConnected = false;
  }
  
  void _handleDisconnect() {
    print('Grok WebSocket disconnected');
    _isConnected = false;
    _transcriptController?.close();
    _audioController?.close();
  }
  
  void _sendConversationItem(String text) {
    _channel?.sink.add(jsonEncode({
      'type': 'conversation.item.create',
      'item': {
        'type': 'message',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': text}
        ],
      },
    }));
  }
  
  void _sendResponseCreate() {
    _channel?.sink.add(jsonEncode({
      'type': 'response.create',
      'response': {
        'modalities': ['text', 'audio'],
        'instructions': 'You are Nexus Dev Orchestrator, a senior DevSecOps engineer. Respond concisely.',
      },
    }));
  }
  
  void sendAudioChunk(List<int> pcmData) {
    if (!_isConnected) return;
    
    final base64Audio = base64Encode(pcmData);
    _channel?.sink.add(jsonEncode({
      'type': 'input_audio_buffer.append',
      'audio': base64Audio,
    }));
  }
  
  void commitAudio() {
    _channel?.sink.add(jsonEncode({'type': 'input_audio_buffer.commit'}));
    _channel?.sink.add(jsonEncode({'type': 'response.create'}));
  }
  
  void sendTextMessage(String text) {
    _sendConversationItem(text);
    _sendResponseCreate();
  }
  
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }
  
  void dispose() {
    disconnect();
    _transcriptController?.close();
    _audioController?.close();
  }
}
