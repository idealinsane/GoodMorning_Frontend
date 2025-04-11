import 'package:flutter_earth_globe/point_connection.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/models/user_profile.dart';

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
}
