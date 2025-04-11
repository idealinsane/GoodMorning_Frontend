import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/user_profile.dart';
import 'package:good_morning/views/chat_room_list_view.dart';
import 'package:good_morning/views/globe_view.dart';

class GoodMorningScreen extends StatefulWidget {
  const GoodMorningScreen({super.key});

  @override
  State<GoodMorningScreen> createState() => _GoodMorningScreenState();
}

class _GoodMorningScreenState extends State<GoodMorningScreen> {
  bool _showGlobe = true; //지구본 보기 여부

  final List<ChatRoom> participatingRooms = [
    ChatRoom(
      id: '1',
      title: '내 채팅방 1',
      participants: [
        UserProfile(uid: 'User1', nickname: 'User1'),
        UserProfile(uid: 'User2', nickname: 'User2'),
      ],
      connection: PointConnection(
        id: '굿모닝이요 - connect1',
        label: 'Connection 1',
        isLabelVisible: true,
        start: GlobeCoordinates(51.5072, -0.1276),
        end: GlobeCoordinates(35.6895, 139.6917),
      ),
      createdAt: DateTime.now(),
    ),
    ChatRoom(
      id: '2',
      title: '내 채팅방 2',
      participants: [
        UserProfile(uid: 'User1', nickname: 'User1'),
        UserProfile(uid: 'User3', nickname: 'User3'),
      ],
      connection: PointConnection(
        id: 'connection2',
        label: 'Connection 2',
        isLabelVisible: true,
        start: GlobeCoordinates(40.7128, -74.0060),
        end: GlobeCoordinates(34.0522, -118.2437),
      ),
      createdAt: DateTime.now(),
    ),
  ];

  final List<ChatRoom> allRooms = List.generate(10, (index) {
    return ChatRoom(
      id: '${index + 1}',
      title: '채팅방 ${index + 1}',
      participants: [
        UserProfile(uid: 'User${index + 1}', nickname: 'User${index + 1}'),
      ],
      connection: PointConnection(
        id: 'connection${index + 3}',
        label: 'Connect ${index + 3}',
        isLabelVisible: true,
        start: GlobeCoordinates(0.0, 0.0),
        end: GlobeCoordinates(10.0, 10.0),
      ),
      createdAt: DateTime.now(),
    );
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // You may want to handle room addition logic here
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
                _showGlobe
                    ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: GlobeView(
                        participatingRooms: participatingRooms,
                        allRooms: allRooms,
                      ),
                    )
                    : ChatRoomListView(
                      participatingRooms: participatingRooms,
                      allRooms: allRooms,
                    ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Switch(
              value: _showGlobe,
              onChanged: (value) {
                setState(() {
                  _showGlobe = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
