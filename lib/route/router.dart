import 'package:go_router/go_router.dart';
import 'package:good_morning/screens/good_morning_screen.dart';
import 'package:good_morning/screens/home_screen.dart';
import 'package:good_morning/screens/login_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return HomeScreen();
      },
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) {
            return LoginScreen();
          },
        ),
        GoRoute(
          path: 'good_morning',
          builder: (context, state) {
            return GoodMorningScreen();
          },
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) {
            return LoginScreen();
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return LoginScreen();
          },
        ),
      ],
    ),
  ],
);
