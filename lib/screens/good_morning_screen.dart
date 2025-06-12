import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:good_morning/constants/showGlobe.dart';
import 'package:good_morning/providers/location_provider.dart';
import 'package:good_morning/providers/chat_rooms_provider.dart';
import 'package:good_morning/views/chat_room_list_view.dart';
import 'package:good_morning/views/create_chat_room_view.dart';
import 'package:good_morning/views/globe_view.dart';

class GoodMorningScreen extends ConsumerStatefulWidget {
  const GoodMorningScreen({super.key});

  @override
  ConsumerState<GoodMorningScreen> createState() => _GoodMorningScreenState();
}

class _GoodMorningScreenState extends ConsumerState<GoodMorningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _getLocation();
    });
  }

  Future<void> _getLocation() async {
    try {
      await ref.read(locationProvider.notifier).updateLocation();
      final location = ref.read(locationProvider);
      if (location != null) {
        Fluttertoast.showToast(
          msg: '위도: ${location.latitude}\n경도: ${location.longitude}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '위치 정보를 가져오는데 실패했습니다: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _showCreateChatRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateChatRoomView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(chatRoomsProvider);

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Center(
            child:
                showGlobe
                    ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: GlobeView(rooms: rooms),
                    )
                    : ChatRoomListView(rooms: rooms),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 지구본/목록 토글
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 목록 버튼
                      Material(
                        color:
                            !showGlobe ? Colors.blue[50] : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (showGlobe) {
                              setState(() => showGlobe = false);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 18,
                                  color:
                                      !showGlobe
                                          ? Colors.blue[700]
                                          : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'List',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        !showGlobe
                                            ? Colors.blue[700]
                                            : Colors.grey[600],
                                    fontWeight:
                                        !showGlobe
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 지구본 버튼
                      Material(
                        color: showGlobe ? Colors.blue[50] : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (!showGlobe) {
                              setState(() => showGlobe = true);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.public,
                                  size: 18,
                                  color:
                                      showGlobe
                                          ? Colors.blue[700]
                                          : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Globe',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        showGlobe
                                            ? Colors.blue[700]
                                            : Colors.grey[600],
                                    fontWeight:
                                        showGlobe
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 채팅방 만들기 버튼
                Material(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showCreateChatRoomDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Create Room',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
