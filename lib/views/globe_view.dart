import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/views/join_chat_room_view.dart';

class GlobeView extends StatefulWidget {
  final List<ChatRoom> rooms;

  const GlobeView({super.key, required this.rooms});

  @override
  State<GlobeView> createState() => _GlobeViewState();
}

class _GlobeViewState extends State<GlobeView>
    with SingleTickerProviderStateMixin {
  late FlutterEarthGlobeController controller;
  final Map<String, Widget> _labelCache = {};

  Widget buildLabel(String id, String text, {required bool isConnected}) {
    final cacheKey = '$id-$isConnected';
    if (_labelCache.containsKey(cacheKey)) {
      return _labelCache[cacheKey]!;
    }

    final label = GestureDetector(
      onTap: () {
        print('Label tapped: $text');
        final room = widget.rooms.firstWhere((r) => r.id == id);
        if (room.participants.length == 1) {
          showDialog(
            context: context,
            builder: (_) => Dialog(child: JoinChatRoomView(room: room)),
          );
        } else {
          context.go('/chat/${room.id}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              isConnected ? const Color(0xFF2196F3) : const Color(0xFFFF7043),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );

    _labelCache[cacheKey] = label;
    return label;
  }

  @override
  void initState() {
    super.initState();
    controller = FlutterEarthGlobeController(
      rotationSpeed: 0.005,
      isBackgroundFollowingSphereRotation: true,
      surface: Image.asset('assets/images/2k_earth-day.jpg').image,
      background: Image.asset('assets/images/2k_stars.jpg').image,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // globe 에 그릴 point, connection은 여기서 추가
      controller.startRotation(rotationSpeed: 0.005);

      // Add points for each room

      for (final room in widget.rooms) {
        // room 내 participants 수가 1명인 경우 point 추가
        if (room.participants.length == 1) {
          controller.addPoint(
            Point(
              id: room.id,
              labelBuilder:
                  (context, point, isSelected, isHovered) =>
                      buildLabel(room.id, room.title, isConnected: false),
              coordinates: room.connection.start,
              onTap: () => print('Point tapped: ${room.id}'),
            ),
          );
        }
        // room 내 participants 수가 2명인 경우 PointConnection 추가
        else if (room.participants.length == 2) {
          controller.addPointConnection(
            PointConnection(
              id: room.connection.id,
              labelBuilder:
                  (context, pointConnection, isSelected, isHovered) =>
                      buildLabel(room.id, room.title, isConnected: true),
              start: room.connection.start,
              end: room.connection.end,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterEarthGlobe(controller: controller, radius: 70),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: Image.asset('assets/images/GM_text.png').image,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
