import 'package:good_morning/views/join_chat_room_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/chat_room.dart';

class ChatRoomCard extends StatelessWidget {
  final ChatRoom room;
  final Color? color;

  const ChatRoomCard({super.key, required this.room, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading:
            room.id.isNotEmpty
                ? CircleAvatar(child: Text(room.id))
                : const Icon(Icons.chat_bubble),
        title: Text(room.title),
        subtitle: Text(
          '참가자: ${room.participants.length}명 • 생성: ${room.createdAt.toLocal().toString().split(' ')[1].split('.')[0]}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                room.participants.length == 1 ? '참여' : '보기',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor:
                  room.participants.length == 1 ? Colors.orange : Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
          ],
        ),
        onTap: () {
          if (room.participants.length == 1) {
            showDialog(
              context: context,
              builder: (_) => Dialog(child: JoinChatRoomView(room: room)),
            );
          } else {
            context.go('/chat/${room.id}');
          }
        },
      ),
    );
  }
}
