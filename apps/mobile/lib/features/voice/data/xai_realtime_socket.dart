import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract interface class XaiRealtimeTransport {
  Stream<Map<String, Object?>> get events;

  Future<void> connect({required Uri uri, required String token});

  Future<void> sendJson(Map<String, Object?> event);

  Future<void> close();
}

final class IoXaiRealtimeSocket implements XaiRealtimeTransport {
  final StreamController<Map<String, Object?>> _events =
      StreamController<Map<String, Object?>>.broadcast();
  WebSocket? _socket;

  @override
  Stream<Map<String, Object?>> get events => _events.stream;

  @override
  Future<void> connect({required Uri uri, required String token}) async {
    final socket = await WebSocket.connect(
      uri.toString(),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );
    _socket = socket;
    socket.listen((Object? raw) {
      if (raw is! String) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) _events.add(decoded);
    }, onError: _events.addError);
  }

  @override
  Future<void> sendJson(Map<String, Object?> event) async {
    final socket = _socket;
    if (socket == null) throw StateError('Realtime socket is not connected');
    socket.add(jsonEncode(event));
  }

  @override
  Future<void> close() async {
    await _socket?.close();
    _socket = null;
  }
}
