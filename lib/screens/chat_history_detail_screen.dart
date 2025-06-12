import 'package:flutter/material.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/user_profile.dart';
import 'dart:ui';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHistoryDetailScreen extends StatefulWidget {
  final ChatRoom room;
  const ChatHistoryDetailScreen({super.key, required this.room});

  @override
  State<ChatHistoryDetailScreen> createState() =>
      _ChatHistoryDetailScreenState();
}

class _ChatHistoryDetailScreenState extends State<ChatHistoryDetailScreen> {
  static const Duration _gradientDuration = Duration(milliseconds: 1800);
  static const Duration _gradientInterval = Duration(milliseconds: 1800);
  final List<List<Color>> _gradientColors = [
    [
      Color(0xFF235390),
      Color(0xFF4F8DFD),
      Color(0xFFA7C7E7),
      Color(0xFFE3F0FF),
    ],
    [
      Color(0xFF4F8DFD),
      Color(0xFF235390),
      Color(0xFFE3F0FF),
      Color(0xFFA7C7E7),
    ],
    [
      Color(0xFFA7C7E7),
      Color(0xFFE3F0FF),
      Color(0xFF235390),
      Color(0xFF4F8DFD),
    ],
  ];
  int _gradientIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_gradientInterval, (timer) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradientColors.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.room.messages;
    final participants = {
      for (var user in widget.room.participants) user.uid: user,
    };
    final currentUser = FirebaseAuth.instance.currentUser;
    final myUid = currentUser?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.room.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: _gradientDuration,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors[_gradientIndex],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    key: ValueKey(widget.room.id),
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
                      final isMine = msg.senderId == myUid;
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
                                                : Colors.white.withOpacity(
                                                  0.85,
                                                ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color:
                                              isMine
                                                  ? Colors.blue[700]!
                                                      .withOpacity(0.7)
                                                  : Colors.blue[200]!
                                                      .withOpacity(0.5),
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
                                                      ? Colors.white
                                                          .withOpacity(0.85)
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
                                                      : Colors.blue,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
