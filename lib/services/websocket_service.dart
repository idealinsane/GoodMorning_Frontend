import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/services/login_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final Map<String, WebSocketChannel> _connections = {};
  final Map<String, StreamController<Message>> _messageControllers = {};
  final String _wsBaseUrl = 'ws://goodmorningkr01.duckdns.org/ws';

  // 특정 채팅방의 메시지 스트림을 구독
  Stream<Message> subscribeToRoom(String roomId) {
    if (!_messageControllers.containsKey(roomId)) {
      _messageControllers[roomId] = StreamController<Message>.broadcast();
    }
    return _messageControllers[roomId]!.stream;
  }

  // 채팅방 웹소켓 연결
  Future<void> connectToRoom(String roomId) async {
    if (_connections.containsKey(roomId)) {
      print('이미 연결된 채팅방입니다: $roomId');
      return;
    }

    try {
      final token =
          LoginService.getAuthHeaders()['Authorization']?.split(' ')[1];
      if (token == null) throw Exception('인증 토큰이 없습니다.');

      final wsUrl = '$_wsBaseUrl/chat/$roomId?token=$token';
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // 메시지 수신 처리
      channel.stream.listen(
        (message) {
          final data = jsonDecode(message);
          final receivedMessage = Message.fromJson(data);
          _messageControllers[roomId]?.add(receivedMessage);
        },
        onError: (error) {
          print('웹소켓 에러 (채팅방 $roomId): $error');
          _cleanupConnection(roomId);
        },
        onDone: () {
          print('웹소켓 연결 종료 (채팅방 $roomId)');
          _cleanupConnection(roomId);
        },
      );

      _connections[roomId] = channel;
      print('채팅방 웹소켓 연결 성공: $roomId');
    } catch (e) {
      print('채팅방 웹소켓 연결 실패: $e');
      _cleanupConnection(roomId);
      rethrow;
    }
  }

  // 메시지 전송
  Future<void> sendMessage(String roomId, Message message) async {
    final channel = _connections[roomId];
    if (channel == null) {
      throw Exception('연결되지 않은 채팅방입니다: $roomId');
    }

    try {
      channel.sink.add(jsonEncode(message.toJson()));
    } catch (e) {
      print('메시지 전송 실패: $e');
      rethrow;
    }
  }

  // 채팅방 연결 해제
  Future<void> disconnectFromRoom(String roomId) async {
    await _cleanupConnection(roomId);
  }

  // 연결 정리
  Future<void> _cleanupConnection(String roomId) async {
    final channel = _connections.remove(roomId);
    if (channel != null) {
      await channel.sink.close();
    }

    final controller = _messageControllers.remove(roomId);
    if (controller != null) {
      await controller.close();
    }
  }

  // 모든 연결 해제
  Future<void> disconnectAll() async {
    final roomIds = _connections.keys.toList();
    for (final roomId in roomIds) {
      await _cleanupConnection(roomId);
    }
  }
}
