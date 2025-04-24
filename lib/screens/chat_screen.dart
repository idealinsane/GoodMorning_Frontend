// lib/screens/chat_room_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/user_profile.dart';
import 'package:uuid/uuid.dart';

import 'package:good_morning/layout/default_layout.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/providers/chat_rooms_provider.dart';
import 'package:good_morning/views/user_profile_popup_view.dart';

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
    final currentUser = FirebaseAuth.instance.currentUser!;
    notifier.appendMessage(
      widget.id,
      Message(
        id: const Uuid().v4(),
        senderId: currentUser.uid,
        content: content,
        timestamp: DateTime.now(),
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final room = ref
        .watch(chatRoomsProvider)
        .firstWhere((room) => room.id == widget.id);

    final messages = room.messages;
    final currentUser = FirebaseAuth.instance.currentUser!;

    // 참가자 정보 미리 가져오기
    final participants = {for (var user in room.participants) user.uid: user};

    return DefaultLayout(
      appBar: AppBar(
        title: Text(room.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/good_morning');
          },
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: ValueKey(room.id),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                final isMine = currentUser.uid == msg.senderId; // 여기서 비교

                // 메시지의 senderId를 사용하여 참가자 정보 찾기

                final sender =
                    participants[msg.senderId] ??
                    UserProfile(uid: msg.senderId, nickname: 'Unknown');

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment:
                          isMine
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      children: [
                        if (!isMine) ...[
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => UserProfilePopupView(
                                      user: sender,
                                      onLike: () {}, // 추후 API 연동을 위한 자리
                                    ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage:
                                  sender.profileImageUrl != null
                                      ? NetworkImage(sender.profileImageUrl!)
                                      : NetworkImage(
                                        'https://placedog.net/100/100',
                                      ),
                              child:
                                  sender.profileImageUrl == null
                                      ? const Icon(Icons.person, size: 16)
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Column(
                          crossAxisAlignment:
                              msg.senderId == currentUser.uid
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Text(
                              sender.nickname,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    msg.senderId == currentUser.uid
                                        ? Colors.blue[100]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(msg.content),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Say good morning!',
                    ),
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
