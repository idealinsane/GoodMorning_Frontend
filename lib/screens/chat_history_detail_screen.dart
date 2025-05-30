import 'package:flutter/material.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/user_profile.dart';
import 'dart:ui';

class ChatHistoryDetailScreen extends StatelessWidget {
  final ChatRoom room;
  const ChatHistoryDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final messages = room.messages;
    final participants = {for (var user in room.participants) user.uid: user};

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(room.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400.withOpacity(0.7),
              Colors.blue.shade200.withOpacity(0.5),
              Colors.white.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  key: ValueKey(room.id),
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemBuilder: (_, index) {
                    final msg = messages[index];
                    final sender =
                        participants[msg.senderId] ??
                        UserProfile(uid: msg.senderId, nickname: 'Unknown');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage:
                                  sender.profileImageUrl != null
                                      ? NetworkImage(sender.profileImageUrl!)
                                      : const NetworkImage(
                                        'https://placedog.net/100/100',
                                      ),
                              child:
                                  sender.profileImageUrl == null
                                      ? const Icon(Icons.person, size: 16)
                                      : null,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.blue[200]!.withOpacity(0.5),
                                      width: 1.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sender.nickname,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[900],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        msg.content,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
