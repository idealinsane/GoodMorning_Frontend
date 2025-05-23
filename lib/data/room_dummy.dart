import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/models/user_profile.dart';

final dummyUsers = [
  UserProfile(
    uid: 'User1',
    nickname: 'User1',
    bio: '여행을 좋아하는 사람입니다.',
    likes: 5,
  ),
  UserProfile(
    uid: '6hzBrI8HXuPZ3hHwxvZwH1VJC7C2',
    nickname: '김민수',
    bio: '개발과 커피를 좋아합니다.',
    likes: 8,
  ),
  UserProfile(
    uid: 'User3',
    nickname: 'User3',
    bio: '혼자 떠나는 모험을 즐깁니다.',
    likes: 2,
  ),
];

final List<ChatRoom> dummyChatRooms = [
  ChatRoom(
    id: '1',
    title: '끝말잇기 고',
    participants: [dummyUsers[0], dummyUsers[1]],
    connection: PointConnection(
      id: '굿모닝이요 - connect1',
      start: GlobeCoordinates(11.5072, -0.1276),
      end: GlobeCoordinates(35.6895, 139.6917),
    ),
    createdAt: DateTime.now(),
    messages: [
      Message(
        id: '1',
        senderId: dummyUsers[0].uid,
        content: '안녕하세요!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        id: '2',
        senderId: dummyUsers[1].uid,
        content: '반갑습니다 😊',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ],
  ),
  ChatRoom(
    id: '2',
    title: '굿모닝~',
    participants: [dummyUsers[1], dummyUsers[2]],
    connection: PointConnection(
      id: 'connection2',
      start: GlobeCoordinates(40.7128, -74.0060),
      end: GlobeCoordinates(10.0, 10.0),
    ),
    createdAt: DateTime.now(),
    messages: [],
  ),
  ChatRoom(
    id: '3',
    title: '혼자 떠나는 여행',
    participants: [dummyUsers[0]], // 1인 채팅방
    connection: PointConnection(
      id: 'solo_connection',
      start: GlobeCoordinates(-33.8688, 151.2093), // Sydney
      end: GlobeCoordinates(48.8566, 2.3522), // Paris
    ),
    createdAt: DateTime.now(),
    messages: [
      Message(
        id: '3',
        senderId: dummyUsers[0].uid,
        content: '파리로 떠나는 여행!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ],
  ),
];
