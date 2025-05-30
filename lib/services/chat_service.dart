import 'package:dio/dio.dart';
import 'package:good_morning/services/login_service.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/services/websocket_service.dart';
import 'package:good_morning/models/message.dart';

class ChatService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://goodmorningkr01.duckdns.org/api/';
  final WebSocketService _wsService = WebSocketService();

  // 채팅방 생성
  Future<void> createChatRoom({
    required String title,
    required List<String> participants,
    required List<Map<String, double>> connection,
  }) async {
    final String endpoint =
        'chatrooms'; // _baseUrl 에 /api/ 가 이미 포함되어 있으므로, 여기서는 'chatrooms'만 사용합니다.
    try {
      final response = await _dio.post(
        _baseUrl + endpoint,
        data: {
          'title': title,
          'connection':
              connection
                  .map(
                    (conn) => {
                      'latitude': conn['latitude'],
                      'longitude': conn['longitude'],
                    },
                  )
                  .toList(),
        },
        options: Options(headers: LoginService.getAuthHeaders()),
      );

      if (response.statusCode == 201) {
        // 성공적으로 생성됨 (HTTP 201 Created)
        print('Chatroom created successfully: ${response.data}');
        // 필요하다면 response.data를 파싱하여 ChatRoom 모델 객체로 반환할 수 있습니다.
      } else {
        // 기타 성공적인 응답 코드 처리 (200 등)
        print(
          'Chatroom creation completed with status: ${response.statusCode}, data: ${response.data}',
        );
      }
    } on DioException catch (e) {
      // Dio 오류 처리 (네트워크 오류, 서버 오류 등)
      print('Error creating chatroom: $e');
      // 필요에 따라 사용자에게 보여줄 오류 메시지를 throw 하거나 상태 관리를 통해 UI에 알릴 수 있습니다.
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
      }
      throw Exception('Failed to create chatroom: ${e.message}');
    } catch (e) {
      // 기타 예외 처리
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred while creating chatroom.');
    }
  }

  // 채팅방 목록 조회
  Future<List<ChatRoom>> getChatRooms({int skip = 0, int limit = 100}) async {
    final String endpoint = 'chatrooms';
    try {
      final response = await _dio.get(
        _baseUrl + endpoint,
        queryParameters: {'skip': skip, 'limit': limit},
        options: Options(
          headers: {
            'accept': 'application/json',
            ...LoginService.getAuthHeaders(),
          },
        ),
      );

      if (response.statusCode == 200) {
        // 응답 데이터가 List<dynamic>인지 확인
        if (response.data is List) {
          final List<dynamic> jsonList = response.data as List<dynamic>;
          // 각 JSON 객체를 ChatRoom 객체로 변환
          return jsonList
              .map((json) => ChatRoom.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Unexpected response format: expected List but got ${response.data.runtimeType}',
          );
        }
      } else {
        throw Exception('Failed to load chat rooms: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error getting chat rooms: $e');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
      }
      throw Exception('Failed to load chat rooms: ${e.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred while loading chat rooms.');
    }
  }

  // 채팅방 참여
  Future<ChatRoom> joinChatRoom(String roomId) async {
    final String endpoint = 'chatrooms/$roomId/join';
    try {
      // 1. REST API로 채팅방 참여
      final response = await _dio.post(
        _baseUrl + endpoint,
        options: Options(headers: LoginService.getAuthHeaders()),
      );

      if (response.statusCode != 200) {
        throw Exception('채팅방 참여 실패: ${response.statusCode}');
      }

      // 2. 채팅방 정보 파싱
      final chatRoom = ChatRoom.fromJson(response.data);

      // 3. 웹소켓 연결
      await _wsService.connectToRoom(roomId);

      return chatRoom;
    } on DioException catch (e) {
      print('채팅방 참여 중 에러 발생: $e');
      rethrow;
    } catch (e) {
      print('채팅방 참여 중 예상치 못한 에러 발생: $e');
      rethrow;
    }
  }

  // 채팅방 나가기
  Future<void> leaveChatRoom(String roomId) async {
    final String endpoint = 'chatrooms/$roomId/leave';
    try {
      // 1. REST API로 채팅방 나가기
      final response = await _dio.post(
        _baseUrl + endpoint,
        options: Options(headers: LoginService.getAuthHeaders()),
      );

      if (response.statusCode != 200) {
        throw Exception('채팅방 나가기 실패: ${response.statusCode}');
      }

      // 2. 웹소켓 연결 해제
      await _wsService.disconnectFromRoom(roomId);
    } catch (e) {
      print('채팅방 나가기 중 에러 발생: $e');
      rethrow;
    }
  }

  // 메시지 전송 (웹소켓)
  Future<void> sendMessage(String roomId, String content) async {
    try {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID
        senderId:
            LoginService.getAuthHeaders()['Authorization']?.split(' ')[1] ?? '',
        content: content,
        timestamp: DateTime.now(),
      );

      await _wsService.sendMessage(roomId, message);
    } catch (e) {
      print('메시지 전송 중 에러 발생: $e');
      rethrow;
    }
  }

  // 채팅방 메시지 구독
  Stream<Message> subscribeToMessages(String roomId) {
    return _wsService.subscribeToRoom(roomId);
  }
}
