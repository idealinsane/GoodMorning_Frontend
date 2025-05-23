import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_morning/route/router.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:good_morning/services/login_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LoginService.loadToken(); // 저장된 토큰 불러오기
  runApp(
    const ProviderScope(
      child: MyApp(), // 여기에 기존 앱 루트 위젯 넣기
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Good Morning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}
