import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:good_morning/layout/default_layout.dart';

class GoodMorningScreen extends StatefulWidget {
  const GoodMorningScreen({super.key});

  @override
  State<GoodMorningScreen> createState() => _GoodMorningScreenState();
}

class _GoodMorningScreenState extends State<GoodMorningScreen> {
  late FlutterEarthGlobeController _controller;

  @override
  initState() {
    _controller = FlutterEarthGlobeController(
      rotationSpeed: 0.05,
      isBackgroundFollowingSphereRotation: true,
      surface: Image.asset('assets/images/2k_earth-day.jpg').image,
      background: Image.asset('assets/images/2k_stars.jpg').image,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text('Good Morning')),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: FlutterEarthGlobe(controller: _controller, radius: 90),
          ),
        ],
      ),
    );
  }
}
