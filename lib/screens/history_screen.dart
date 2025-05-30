import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/services/chat_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:good_morning/models/user_profile.dart';
import 'package:good_morning/models/location_model.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:good_morning/models/message.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _now = DateTime.now();
  late final DateTime _firstDay;
  late final DateTime _lastDay;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<ChatRoom>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firstDay = DateTime(_now.year - 1, 1, 1);
    _lastDay = DateTime(_now.year + 1, 12, 31);
    _focusedDay = _now;
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();

    // 더미 유저
    final user1 = UserProfile(
      uid: 'u1',
      nickname: '홍길동',
      bio: 'Flutter 개발자',
      profileImageUrl: null,
      likes: 10,
    );
    final user2 = UserProfile(
      uid: 'u2',
      nickname: '김철수',
      bio: '백엔드 개발자',
      profileImageUrl: null,
      likes: 5,
    );

    final may25 = DateTime(2025, 5, 10, 14, 30);
    final may26 = DateTime(2025, 5, 26, 9, 0);
    final june1 = DateTime(2025, 6, 1, 18, 45);
    final june10 = DateTime(2025, 6, 10, 20, 15);
    final june13 = DateTime(2025, 6, 13, 8, 0);

    // 더미 채팅방
    final dummyRooms = [
      ChatRoom(
        id: '1',
        title: 'Flutter Study',
        participants: [user1, user2],
        connection: PointConnection(
          id: 'c1',
          start: GlobeCoordinates(37.5665, 126.9780), // 서울
          end: GlobeCoordinates(35.1796, 129.0756), // 부산
        ),
        createdAt: may25,
        messages: [
          Message(
            id: 'm1',
            content: '안녕하세요!',
            timestamp: may25,
            senderId: 'u1',
          ),
          Message(
            id: 'm2',
            content: '오늘 스터디 몇 시에 시작해요?',
            timestamp: may26,
            senderId: 'u2',
          ),
        ],
      ),
      ChatRoom(
        id: '2',
        title: '친구들',
        participants: [user1],
        connection: PointConnection(
          id: 'c2',
          start: GlobeCoordinates(37.5665, 126.9780),
          end: GlobeCoordinates(37.5665, 126.9780),
        ),
        createdAt: june1,
        messages: [
          Message(
            id: 'm3',
            content: '주말에 뭐해?',
            timestamp: june1,
            senderId: 'u1',
          ),
        ],
      ),
      ChatRoom(
        id: '3',
        title: '회사',
        participants: [user2],
        connection: PointConnection(
          id: 'c3',
          start: GlobeCoordinates(35.1796, 129.0756),
          end: GlobeCoordinates(35.1796, 129.0756),
        ),
        createdAt: june10,
        messages: [
          Message(
            id: 'm4',
            content: '회의 자료 준비됐나요?',
            timestamp: june10,
            senderId: 'u2',
          ),
          Message(
            id: 'm5',
            content: '네, 준비 완료입니다!',
            timestamp: june13,
            senderId: 'u2',
          ),
        ],
      ),
    ];

    final events = <DateTime, List<ChatRoom>>{};
    for (final room in dummyRooms) {
      if (room.messages.isNotEmpty) {
        final lastMessage = room.messages.last;
        final date = DateTime(
          lastMessage.timestamp.year,
          lastMessage.timestamp.month,
          lastMessage.timestamp.day,
        );
        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(room);
      }
    }

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  List<ChatRoom> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
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
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    const SizedBox(height: 32),
                    // Glassmorphism 캘린더 카드
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TableCalendar(
                                firstDay: _firstDay,
                                lastDay: _lastDay,
                                focusedDay:
                                    _focusedDay.isBefore(_firstDay)
                                        ? _firstDay
                                        : (_focusedDay.isAfter(_lastDay)
                                            ? _lastDay
                                            : _focusedDay),
                                calendarFormat: _calendarFormat,
                                eventLoader: _getEventsForDay,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                onFormatChanged: (format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                },
                                calendarStyle: CalendarStyle(
                                  markersMaxCount: 3,
                                  markerDecoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  outsideDaysVisible: false,
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  weekendStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Glassmorphism 이벤트 리스트 카드
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child:
                                  _selectedDay == null
                                      ? const Center(
                                        child: Text(
                                          '날짜를 선택해주세요',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                      : _buildEventList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);
    if (events.isEmpty) {
      return const Center(
        child: Text(
          '해당 날짜의 채팅 기록이 없습니다',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final room = events[index];
        final lastMessage =
            room.messages.isNotEmpty ? room.messages.last : null;

        return Card(
          color: Colors.white.withOpacity(0.7),
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: ListTile(
            onTap: () {
              final now = DateTime.now();
              final isReadOnly = now.difference(room.createdAt).inHours >= 24;
              context.push('/chat/${room.id}', extra: {'readOnly': isReadOnly});
            },
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                room.title[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              room.title,
              style: const TextStyle(color: Colors.black),
            ),
            subtitle:
                lastMessage != null
                    ? Text(
                      '${lastMessage.content} • ${DateFormat('HH:mm').format(lastMessage.timestamp)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    )
                    : const Text(
                      '메시지 없음',
                      style: TextStyle(color: Colors.black54),
                    ),
            trailing: const Icon(Icons.chevron_right, color: Colors.black45),
          ),
        );
      },
    );
  }
}
