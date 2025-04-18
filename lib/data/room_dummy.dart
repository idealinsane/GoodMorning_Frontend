import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/user_profile.dart';

final List<ChatRoom> rooms = [
  ChatRoom(
    id: '1',
    title: '끝말잇기 고',
    participants: [
      UserProfile(uid: 'User1', nickname: 'User1'),
      UserProfile(uid: '6hzBrI8HXuPZ3hHwxvZwH1VJC7C2', nickname: 'User2'),
    ],
    connection: PointConnection(
      id: '굿모닝이요 - connect1',
      start: GlobeCoordinates(11.5072, -0.1276),
      end: GlobeCoordinates(35.6895, 139.6917),
    ),
    createdAt: DateTime.now(),
  ),
  ChatRoom(
    id: '2',
    title: '굿모닝~',
    participants: [
      UserProfile(uid: '6hzBrI8HXuPZ3hHwxvZwH1VJC7C2', nickname: 'User1'),
      UserProfile(uid: 'User3', nickname: 'User3'),
    ],
    connection: PointConnection(
      id: 'connection2',
      start: GlobeCoordinates(40.7128, -74.0060),
      end: GlobeCoordinates(34.0522, -118.2437),
    ),
    createdAt: DateTime.now(),
  ),
  ChatRoom(
    id: '3',
    title: 'GoodMorning yo',
    participants: [UserProfile(uid: 'User1', nickname: 'User1')],
    connection: PointConnection(
      id: 'connection3',
      start: GlobeCoordinates(-10, 0.0),
      end: GlobeCoordinates(10.0, 10.0),
    ),
    createdAt: DateTime.now(),
  ),
  ChatRoom(
    id: '4',
    title: 'Good Day!',
    participants: [UserProfile(uid: 'User2', nickname: 'User2')],
    connection: PointConnection(
      id: 'connection4',
      start: GlobeCoordinates(30, 0.0),
      end: GlobeCoordinates(10.0, 10.0),
    ),
    createdAt: DateTime.now(),
  ),
  ChatRoom(
    id: '5',
    title: 'Just Do It',
    participants: [
      UserProfile(uid: '6hzBrI8HXuPZ3hHwxvZwH1VJC7C2', nickname: 'User3'),
    ],
    connection: PointConnection(
      id: 'connection5',
      start: GlobeCoordinates(-90, 0.0),
      end: GlobeCoordinates(10.0, 10.0),
    ),
    createdAt: DateTime.now(),
  ),
];
