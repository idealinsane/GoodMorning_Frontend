import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:go_router/go_router.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
      children: [
        SizedBox(height: 50),
        if (participatingRooms.isNotEmpty) ...[
          _SectionTitle('Participating'),
          const SizedBox(height: 8),
          ...participatingRooms.map(
            (room) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _ModernChatRoomCard(room: room, highlight: true),
            ),
          ),
          const SizedBox(height: 24),
        ],
        _SectionTitle('All Chat Rooms'),
        const SizedBox(height: 8),
        ...otherRooms.map(
          (room) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _ModernChatRoomCard(room: room),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: Colors.grey[200], thickness: 1, height: 1),
          ),
        ],
      ),
    );
  }
}

class _ModernChatRoomCard extends StatelessWidget {
  final ChatRoom room;
  final bool highlight;
  const _ModernChatRoomCard({required this.room, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color:
              highlight
                  ? const Color.fromRGBO(33, 150, 243, 0.10)
                  : const Color.fromRGBO(255, 255, 255, 0.55),
          borderRadius: BorderRadius.circular(18),
          elevation: highlight ? 4 : 2,
          shadowColor: Colors.black.withAlpha(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              context.go('/chat/${room.id}');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: highlight ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: highlight ? Colors.blue[700] : Colors.grey[600],
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[900],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${room.participants.length} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
