import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/chat_room.dart';

class JoinChatRoomView extends StatelessWidget {
  final ChatRoom room;

  const JoinChatRoomView({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final host = room.participants.first;
    final profileImageUrl =
        host.profileImageUrl?.isNotEmpty == true
            ? host.profileImageUrl!
            : 'https://placedog.net/100/100';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          const SizedBox(height: 16),
          Text(
            '방 제목: ${room.title}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('개설자: ${host.nickname}', style: const TextStyle(fontSize: 16)),
          if (host.bio != null && host.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                host.bio!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.redAccent, size: 20),
              const SizedBox(width: 4),
              Text('${host.likes}'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.go('/chat/${room.id}');
                },
                child: const Text("입장"),
              ),
              OutlinedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text("취소"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
