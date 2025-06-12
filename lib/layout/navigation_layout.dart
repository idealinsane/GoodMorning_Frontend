import 'package:flutter/material.dart';
import 'package:good_morning/components/bottom_navigation_bar.dart';

class NavigationLayout extends StatelessWidget {
  const NavigationLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(top: false, child: child),
      bottomNavigationBar: BottomNavigationBarGM(),
    );
  }
}
