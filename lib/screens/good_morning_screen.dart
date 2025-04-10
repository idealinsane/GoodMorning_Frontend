import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';

class GoodMorningScreen extends StatefulWidget {
  const GoodMorningScreen({super.key});

  @override
  State<GoodMorningScreen> createState() => _GoodMorningScreenState();
}

class _GoodMorningScreenState extends State<GoodMorningScreen> {
  late FlutterEarthGlobeController _controller;

  @override
  initState() {
    super.initState();
    _controller = FlutterEarthGlobeController(
      rotationSpeed: 0.25,
      isBackgroundFollowingSphereRotation: true,
      surface: Image.asset('assets/images/2k_earth-day.jpg').image,
      background: Image.asset('assets/images/2k_stars.jpg').image,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Good Morning'),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: FlutterEarthGlobe(controller: _controller, radius: 90),
        ),
      ],
    );
  }
}
