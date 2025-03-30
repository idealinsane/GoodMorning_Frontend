import 'package:flutter/material.dart';

class GoodMorningScreen extends StatefulWidget {
  const GoodMorningScreen({super.key});

  @override
  State<GoodMorningScreen> createState() => _GoodMorningScreenState();
}

class _GoodMorningScreenState extends State<GoodMorningScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Good Morning'));
  }
}
