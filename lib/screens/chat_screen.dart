// lib/screens/chat_room_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/user_profile.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';

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
    final goRouterState = GoRouterState.of(context);
    final args = goRouterState.extra as Map<String, dynamic>?;
    final readOnly = args?['readOnly'] ?? false;

    final room = ref
        .watch(chatRoomsProvider)
        .firstWhere((room) => room.id == widget.id);

    final messages = room.messages;
    final currentUser = FirebaseAuth.instance.currentUser!;

    // 참가자 정보 미리 가져오기
    final participants = {for (var user in room.participants) user.uid: user};

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              // Glassmorphism AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              context.go('/good_morning');
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              room.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // 메시지 리스트
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
                    final isMine = currentUser.uid == msg.senderId;
                    final sender =
                        participants[msg.senderId] ??
                        UserProfile(uid: msg.senderId, nickname: 'Unknown');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Align(
                        alignment:
                            isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment:
                              isMine
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMine)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      sender.profileImageUrl != null
                                          ? NetworkImage(
                                            sender.profileImageUrl!,
                                          )
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          isMine
                                              ? Colors.blue[600]!.withOpacity(
                                                0.85,
                                              )
                                              : Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color:
                                            isMine
                                                ? Colors.blue[700]!.withOpacity(
                                                  0.7,
                                                )
                                                : Colors.blue[200]!.withOpacity(
                                                  0.5,
                                                ),
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
                                            color:
                                                isMine
                                                    ? Colors.white.withOpacity(
                                                      0.85,
                                                    )
                                                    : Colors.blue[900],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          msg.content,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            color:
                                                isMine
                                                    ? Colors.white
                                                    : Colors.blue[900],
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
                            if (isMine) const SizedBox(width: 6),
                            if (isMine)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue[100],
                                child: const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Colors.white30),
              // 입력창
              if (!readOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Say good morning!',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                onSubmitted: _sendMessage,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.blue),
                              onPressed: () {
                                if (_controller.text.trim().isNotEmpty) {
                                  _sendMessage(_controller.text);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (readOnly)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '이 채팅방은 생성된 지 24시간이 지나 더 이상 채팅을 보낼 수 없습니다.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
