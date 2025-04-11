import 'package:flutter/material.dart';

import 'package:good_morning/components/chat_card.dart';
import 'package:good_morning/models/chat_room.dart';

class ChatRoomListView extends StatelessWidget {
  final List<ChatRoom> participatingRooms;
  final List<ChatRoom> allRooms;

  const ChatRoomListView({
    super.key,
    required this.participatingRooms,
    required this.allRooms,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        const Text(
          '참여 중인 채팅방',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...participatingRooms.map(
          (room) => ChatRoomCard(room: room, color: Colors.lightBlue[50]),
        ),
        const SizedBox(height: 20),
        const Text(
          '전체 채팅방',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...allRooms.map((room) => ChatRoomCard(room: room)),
      ],
    );
  }
}
