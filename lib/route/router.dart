import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/screens/chat_screen.dart';
import 'package:good_morning/screens/edit_profile_screen.dart';
import 'package:good_morning/screens/error_screen.dart';
import 'package:good_morning/screens/good_morning_screen.dart';
import 'package:good_morning/screens/history_screen.dart';
import 'package:good_morning/screens/home_screen.dart';
import 'package:good_morning/screens/login_screen.dart';
import 'package:good_morning/screens/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }

    if (isLoggedIn && isLoginRoute) {
      return '/good_morning';
    }

    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/good_morning',
          builder: (context, state) {
            return GoodMorningScreen();
          },
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) {
            return HistoryScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            return ProfileScreen();
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                return EditProfileScreen();
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      path: '/chat/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return ChatRoomScreen(id: roomId);
      },
    ),
  ],
  errorBuilder: (context, state) {
    return ErrorScreen(error: state.error.toString());
  },
  debugLogDiagnostics: true, // 디버깅 용 로그 출력
);
