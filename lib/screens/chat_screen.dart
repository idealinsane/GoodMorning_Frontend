// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/providers/chat_rooms_provider.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String id;

  const ChatRoomScreen({super.key, required this.id});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String content) {
    final notifier = ref.read(chatRoomsProvider.notifier);
    notifier.appendMessage(
      widget.id,
      Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'User1',
        content: content,
        timestamp: DateTime.now(),
        isMine: true,
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final room = ref
        .watch(chatRoomsProvider)
        .firstWhere(
          (room) => room.id == widget.id,
          orElse:
              () => ChatRoom(
                id: widget.id,
                title: '채팅방',
                participants: [],
                connection: PointConnection(
                  id: 'default_connection',
                  label: '기본 연결',
                  start: GlobeCoordinates(0.0, 0.0),
                  end: GlobeCoordinates(0.0, 0.0),
                ),
                createdAt: DateTime.now(),
              ),
        );
    print('메시지 수: ${room.messages.length}');

    final messages = room.messages;

    return Scaffold(
      appBar: AppBar(title: Text(room.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: ValueKey(room.id),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                return Align(
                  alignment:
                      msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg.isMine ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg.content),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '메시지 입력'),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
