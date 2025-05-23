import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarGM extends StatelessWidget {
  const BottomNavigationBarGM({super.key});

  int _getIdx(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri == '/good_morning') {
      return 0;
    } else if (uri == '/history') {
      return 1;
    } else if (uri == '/profile') {
      return 2;
    }
    return 0;
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.sunny), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      elevation: 0,
    );
  }
}
