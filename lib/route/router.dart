import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/screens/error_screen.dart';
import 'package:good_morning/screens/good_morning_screen.dart';
import 'package:good_morning/screens/history_screen.dart';
import 'package:good_morning/screens/home_screen.dart';
import 'package:good_morning/screens/login_screen.dart';
import 'package:good_morning/screens/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/good_morning',
  redirect: (context, state) {
    if (FirebaseAuth.instance.currentUser != null) {
      print(FirebaseAuth.instance.currentUser);
      return null; // 라우팅 경로로 이동
    }
    return '/login';
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return HomeScreen(child: GoodMorningScreen());
      },
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return HomeScreen(child: child);
          },
          routes: [
            GoRoute(
              path: 'good_morning',
              builder: (context, state) {
                return GoodMorningScreen();
              },
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) {
                return HistoryScreen();
              },
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) {
                return ProfileScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: 'login',
          builder: (context, state) {
            return LoginScreen();
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) {
    return ErrorScreen(error: state.error.toString());
  },
  debugLogDiagnostics: true, // 디버깅 용 로그 출력
);
