import 'package:flutter_earth_globe/point_connection.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/models/user_profile.dart';
import 'package:good_morning/models/location_model.dart';

class ChatRoom {
  final String id;
  final String title;
  final List<UserProfile> participants;
  final PointConnection connection;
  final DateTime createdAt;
  final List<Message> messages;

  ChatRoom({
    required this.id,
    required this.title,
    required this.participants,
    required this.connection,
    required this.createdAt,
    this.messages = const [],
  });

  // JSON에서 ChatRoom 객체 생성
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final connectionPoints =
        (json['connection'] as List)
            .map(
              (point) => GlobeCoordinates(
                (point['latitude'] as num).toDouble(),
                (point['longitude'] as num).toDouble(),
              ),
            )
            .toList();

    return ChatRoom(
      id: json['id'] as String,
      title: json['title'] as String,
      participants:
          (json['participants'] as List)
              .map((p) => UserProfile.fromJson(p as Map<String, dynamic>))
              .toList(),
      connection: PointConnection(
        id: json['id'], // 채팅방 ID를 connection ID로 사용
        start: connectionPoints.first,
        end: connectionPoints.last,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages:
          json['Message'] != null
              ? (json['Message'] as List)
                  .map((m) => Message.fromJson(m as Map<String, dynamic>))
                  .toList()
              : [],
    );
  }

  // JSON 리스트에서 ChatRoom 리스트 생성
  static List<ChatRoom> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ChatRoom.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  ChatRoom copyWith({
    String? id,
    String? title,
    List<UserProfile>? participants,
    PointConnection? connection,
    DateTime? createdAt,
    List<Message>? messages,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      participants: participants ?? this.participants,
      connection: connection ?? this.connection,
      createdAt: createdAt ?? this.createdAt,
      messages: messages ?? this.messages,
    );
  }
}
