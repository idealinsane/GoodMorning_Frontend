import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:good_morning/models/user_profile.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/screens/chat_history_detail_screen.dart';
import 'package:good_morning/services/user_service.dart';
import 'dart:async';

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

  // Gradient 애니메이션 관련 변수 추가 (login_screen.dart에서 복사)
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
    // Gradient 애니메이션 타이머 세팅
    _timer = Timer.periodic(_gradientInterval, (timer) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradientColors.length;
      });
    });
    _firstDay = DateTime(_now.year - 1, 1, 1);
    _lastDay = DateTime(_now.year + 1, 12, 31);
    _focusedDay = _now;
    _loadChatRooms();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // 내 프로필 불러오기
    final me = await UserService.getCurrentUserProfile();

    // 다른 더미 유저
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
        title: 'Good Morning',
        participants: [me, user2],
        connection: PointConnection(
          id: 'c1',
          start: GlobeCoordinates(37.5665, 126.9780), // 서울
          end: GlobeCoordinates(35.1796, 129.0756), // 부산
        ),
        createdAt: may25,
        messages: [
          Message(
            id: 'm1',
            content: '굿모닝! 오늘도 좋은 하루 보내세요 ☀️',
            timestamp: may25,
            senderId: me.uid,
          ),
          Message(
            id: 'm2',
            content: '좋은 아침이에요! 오늘은 날씨가 참 좋네요.',
            timestamp: may25.add(const Duration(minutes: 2)),
            senderId: user2.uid,
          ),
          Message(
            id: 'm3',
            content: '네! 출근길에 햇살이 기분 좋게 해주네요 :)',
            timestamp: may25.add(const Duration(minutes: 5)),
            senderId: me.uid,
          ),
          Message(
            id: 'm4',
            content: '오늘 일정 많으신가요?',
            timestamp: may25.add(const Duration(minutes: 7)),
            senderId: user2.uid,
          ),
          Message(
            id: 'm5',
            content: '아니요, 오늘은 여유롭게 시작해보려구요. 힘내세요!',
            timestamp: may25.add(const Duration(minutes: 10)),
            senderId: me.uid,
          ),
          Message(
            id: 'm6',
            content: '고마워요! 우리 모두 파이팅입니다 :)',
            timestamp: may25.add(const Duration(minutes: 12)),
            senderId: user2.uid,
          ),
        ],
      ),
      ChatRoom(
        id: '2',
        title: 'Night Shift Support',
        participants: [me],
        connection: PointConnection(
          id: 'c2',
          start: GlobeCoordinates(37.5665, 126.9780),
          end: GlobeCoordinates(37.5665, 126.9780),
        ),
        createdAt: june1,
        messages: [
          Message(
            id: 'm7',
            content: '새벽 근무 중이에요. 조금 피곤하지만 힘내고 있어요!',
            timestamp: june1,
            senderId: me.uid,
          ),
          Message(
            id: 'm8',
            content: '저도 지금 야간 근무 중이에요. 같이 힘내요!',
            timestamp: june1.add(const Duration(minutes: 3)),
            senderId: user2.uid,
          ),
          Message(
            id: 'm9',
            content: '이 시간에 함께 이야기할 수 있어서 든든하네요.',
            timestamp: june1.add(const Duration(minutes: 6)),
            senderId: me.uid,
          ),
          Message(
            id: 'm10',
            content: '맞아요! 서로 응원하면서 버텨봐요 :)',
            timestamp: june1.add(const Duration(minutes: 8)),
            senderId: user2.uid,
          ),
          Message(
            id: 'm11',
            content: '곧 아침이네요. 조금만 더 힘내요!',
            timestamp: june1.add(const Duration(minutes: 12)),
            senderId: me.uid,
          ),
          Message(
            id: 'm12',
            content: '응원해주셔서 고마워요. 오늘도 파이팅입니다!',
            timestamp: june1.add(const Duration(minutes: 15)),
            senderId: user2.uid,
          ),
        ],
      ),
      ChatRoom(
        id: '3',
        title: 'Daily Cheer',
        participants: [user2, me],
        connection: PointConnection(
          id: 'c3',
          start: GlobeCoordinates(35.1796, 129.0756),
          end: GlobeCoordinates(35.1796, 129.0756),
        ),
        createdAt: june10,
        messages: [
          Message(
            id: 'm13',
            content: '오늘 하루도 힘내세요! 작은 응원 보내요 😊',
            timestamp: june10,
            senderId: user2.uid,
          ),
          Message(
            id: 'm14',
            content: '고마워요! 덕분에 힘이 나네요.',
            timestamp: june10.add(const Duration(minutes: 2)),
            senderId: me.uid,
          ),
          Message(
            id: 'm15',
            content: '혹시 오늘 힘든 일 있으셨나요?',
            timestamp: june10.add(const Duration(minutes: 4)),
            senderId: user2.uid,
          ),
          Message(
            id: 'm16',
            content: '조금 지쳤지만 이렇게 응원받으니 괜찮아졌어요.',
            timestamp: june10.add(const Duration(minutes: 7)),
            senderId: me.uid,
          ),
          Message(
            id: 'm17',
            content: '서로 응원하면서 하루를 마무리해요!',
            timestamp: june10.add(const Duration(minutes: 10)),
            senderId: user2.uid,
          ),
          Message(
            id: 'm18',
            content: '네! 오늘도 고생 많으셨고, 내일도 좋은 하루 보내세요 :)',
            timestamp: june10.add(const Duration(minutes: 13)),
            senderId: me.uid,
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
      body: Stack(
        children: [
          // AnimatedContainer로 gradient 애니메이션 적용
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
          // 기존 위젯 구조 유지
          Container(
            padding: EdgeInsets.only(top: 32),
            color: Colors.transparent, // 배경 투명하게
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
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
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
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
        ],
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatHistoryDetailScreen(room: room),
                ),
              );
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
