import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:good_morning/data/room_dummy.dart';

class ChatRoomsNotifier extends StateNotifier<List<ChatRoom>> {
  ChatRoomsNotifier() : super(dummyChatRooms);

  // 채팅방 생성
  Future<ChatRoom> createRoom({
    required String title,
    required String firstMessage,
    required UserProfile creator,
    required double latitude,
    required double longitude,
  }) async {
    final roomId = const Uuid().v4();
    final now = DateTime.now();

    final room = ChatRoom(
      id: roomId,
      title: title,
      participants: [creator],
      connection: PointConnection(
        id: 'connection_$roomId',
        start: GlobeCoordinates(latitude, longitude),
        end: GlobeCoordinates(latitude, longitude), // 임시로 같은 위치 사용
      ),
      createdAt: now,
      messages: [
        Message(
          id: const Uuid().v4(),
          senderId: creator.uid,
          content: firstMessage,
          timestamp: now,
        ),
      ],
    );

    // TODO: 서버에 채팅방 생성 요청
    // final response = await http.post(
    //   Uri.parse('https://api.goodmorning.com/chatrooms'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'title': title,
    //     'participants': [creator.uid],
    //     'connection': {
    //       'start': {'latitude': latitude, 'longitude': longitude},
    //       'end': {'latitude': latitude, 'longitude': longitude},
    //     },
    //     'firstMessage': firstMessage,
    //   }),
    // );

    // if (response.statusCode != 201) {
    //   throw Exception('채팅방 생성에 실패했습니다: ${response.body}');
    // }

    // 로컬 상태 업데이트
    state = [...state, room];
    return room;
  }

  // 채팅방 참여
  Future<void> joinRoom(String roomId, UserProfile user) async {
    final roomIndex = state.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) {
      throw Exception('채팅방을 찾을 수 없습니다.');
    }

    final room = state[roomIndex];
    if (room.participants.length >= 2) {
      throw Exception('채팅방이 가득 찼습니다.');
    }

    if (room.participants.any((p) => p.uid == user.uid)) {
      throw Exception('이미 참여 중인 채팅방입니다.');
    }

    // TODO: 서버에 참여 요청
    // final response = await http.post(
    //   Uri.parse('https://api.goodmorning.com/chatrooms/$roomId/join'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'userId': user.uid}),
    // );

    // if (response.statusCode != 200) {
    //   throw Exception('채팅방 참여에 실패했습니다: ${response.body}');
    // }

    // 로컬 상태 업데이트
    final updatedRoom = room.copyWith(
      participants: [...room.participants, user],
    );
    state = [
      for (final r in state)
        if (r.id == roomId) updatedRoom else r,
    ];
  }

  // 메시지 추가
  Future<void> appendMessage(String roomId, Message message) async {
    final roomIndex = state.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) {
      throw Exception('채팅방을 찾을 수 없습니다.');
    }

    // TODO: 서버에 메시지 전송
    // final response = await http.post(
    //   Uri.parse('https://api.goodmorning.com/chatrooms/$roomId/messages'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'senderId': message.senderId,
    //     'content': message.content,
    //     'timestamp': message.timestamp.toIso8601String(),
    //   }),
    // );

    // if (response.statusCode != 201) {
    //   throw Exception('메시지 전송에 실패했습니다: ${response.body}');
    // }

    // 로컬 상태 업데이트
    state = [
      for (final room in state)
        if (room.id == roomId)
          room.copyWith(messages: [...room.messages, message])
        else
          room,
    ];
  }

  // 채팅방 목록 새로고침
  Future<void> refreshRooms() async {
    // TODO: 서버에서 채팅방 목록 가져오기
    // final response = await http.get(
    //   Uri.parse('https://api.goodmorning.com/chatrooms'),
    // );

    // if (response.statusCode != 200) {
    //   throw Exception('채팅방 목록을 가져오는데 실패했습니다: ${response.body}');
    // }

    // final List<dynamic> roomsJson = jsonDecode(response.body);
    // final rooms = roomsJson.map((json) => ChatRoom.fromJson(json)).toList();
    // state = rooms;
  }

  // 채팅방 나가기
  Future<void> leaveRoom(String roomId, String userId) async {
    final roomIndex = state.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) {
      throw Exception('채팅방을 찾을 수 없습니다.');
    }

    final room = state[roomIndex];
    if (!room.participants.any((p) => p.uid == userId)) {
      throw Exception('참여 중이 아닌 채팅방입니다.');
    }

    // TODO: 서버에 나가기 요청
    // final response = await http.post(
    //   Uri.parse('https://api.goodmorning.com/chatrooms/$roomId/leave'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'userId': userId}),
    // );

    // if (response.statusCode != 200) {
    //   throw Exception('채팅방 나가기에 실패했습니다: ${response.body}');
    // }

    // 로컬 상태 업데이트
    final updatedRoom = room.copyWith(
      participants: room.participants.where((p) => p.uid != userId).toList(),
    );
    state = [
      for (final r in state)
        if (r.id == roomId) updatedRoom else r,
    ];
  }
}

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>((ref) {
      return ChatRoomsNotifier();
    });
