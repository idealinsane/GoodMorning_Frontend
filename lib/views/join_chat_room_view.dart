import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:async';

class JoinChatRoomView extends StatefulWidget {
  final ChatRoom room;

  const JoinChatRoomView({super.key, required this.room});

  @override
  State<JoinChatRoomView> createState() => _JoinChatRoomViewState();
}

class _JoinChatRoomViewState extends State<JoinChatRoomView> {
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
    final host = widget.room.participants.first;
    final profileImageUrl =
        host.profileImageUrl?.isNotEmpty == true
            ? host.profileImageUrl!
            : 'https://placedog.net/100/100';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Animated gradient background
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
          LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = MediaQuery.of(context).size.height;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                    maxWidth: 350,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 144,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 38,
                                backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                widget.room.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                host.nickname,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (host.bio != null && host.bio!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    host.bio!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${host.likes}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 128),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF4F8DFD,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.blueAccent
                                            .withOpacity(0.2),
                                      ),
                                      onPressed: () {
                                        context.go('/chat/${widget.room.id}');
                                      },
                                      child: const Text("Join"),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.7),
                                          width: 1.3,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
