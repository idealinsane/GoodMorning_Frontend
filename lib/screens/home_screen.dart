import 'package:flutter/material.dart';

import 'package:good_morning/layout/navigation_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NavigationLayout(child: child);
  }
}
