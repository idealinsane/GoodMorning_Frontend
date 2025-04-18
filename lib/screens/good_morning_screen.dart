import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_morning/constants/showGlobe.dart';
import 'package:good_morning/data/room_dummy.dart';
import 'package:good_morning/providers/chat_rooms_provider.dart';
import 'package:good_morning/views/chat_room_list_view.dart';
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
      // You may want to handle room addition logic here
      final notifier = ref.read(chatRoomsProvider.notifier);
      for (final room in rooms) {
        notifier.addRoom(room);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Center(
            child:
                showGlobe
                    ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: GlobeView(rooms: rooms),
                    )
                    : ChatRoomListView(rooms: rooms),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Switch(
              value: showGlobe,
              onChanged: (value) {
                setState(() {
                  showGlobe = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
