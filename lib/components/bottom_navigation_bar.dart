import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarGM extends StatelessWidget {
  const BottomNavigationBarGM({super.key});

  _getIdx(BuildContext context) {
    if (GoRouterState.of(context).uri.toString() == '/good_morning') {
      return 0;
    } else if (GoRouterState.of(context).uri.toString() == '/history') {
      return 1;
    } else if (GoRouterState.of(context).uri.toString() == '/profile') {
      return 2;
    }
    return 0; // 예외 처리
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getIdx(context),
      onTap: (value) {
        switch (value) {
          case 0:
            context.go('/good_morning');
            break;
          case 1:
            context.go('/history');
            break;
          case 2:
            context.go('/profile');
            break;
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.sunny), label: 'Good Morning'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
