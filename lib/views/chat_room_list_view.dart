import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_morning/components/chat_card.dart';
import 'package:good_morning/models/chat_room.dart';

class ChatRoomListView extends StatelessWidget {
  final List<ChatRoom> rooms;

  const ChatRoomListView({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final participatingRooms =
        rooms
            .where((room) => room.participants.any((p) => p.uid == uid))
            .toList();
    final otherRooms =
        rooms
            .where((room) => room.participants.every((p) => p.uid != uid))
            .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        if (participatingRooms.isNotEmpty) ...[
          const Text(
            '참여 중인 채팅방',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...participatingRooms.map(
            (room) => ChatRoomCard(room: room, color: Colors.lightBlue[50]),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          '전체 채팅방',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...otherRooms.map((room) => ChatRoomCard(room: room)),
      ],
    );
  }
}
