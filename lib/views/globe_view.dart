import 'package:flutter/widgets.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:good_morning/models/chat_room.dart';

class GlobeView extends StatefulWidget {
  final List<ChatRoom> participatingRooms;
  final List<ChatRoom> allRooms;

  const GlobeView({
    super.key,
    required this.participatingRooms,
    required this.allRooms,
  });

  @override
  State<GlobeView> createState() => _GlobeViewState();
}

class _GlobeViewState extends State<GlobeView>
    with SingleTickerProviderStateMixin {
  late FlutterEarthGlobeController controller;

  @override
  void initState() {
    super.initState();
    controller = FlutterEarthGlobeController(
      rotationSpeed: 0.01,
      isBackgroundFollowingSphereRotation: true,
      surface: Image.asset('assets/images/2k_earth-day.jpg').image,
      background: Image.asset('assets/images/2k_stars.jpg').image,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // globe 에 그릴 point, connection은 여기서 추가
      controller.startRotation(rotationSpeed: 0.01);

      for (final room in widget.participatingRooms + widget.allRooms) {
        controller.addPointConnection(
          PointConnection(
            id: room.connection.id,
            label: room.connection.label,
            isLabelVisible: true,
            start: room.connection.start,
            end: room.connection.end,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEarthGlobe(controller: controller, radius: 70);
  }
}
