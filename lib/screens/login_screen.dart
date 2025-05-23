import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/layout/default_layout.dart';
import 'package:good_morning/services/login_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Good Morning',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 80),
            Image.asset('assets/images/logo.png', width: 200),
            SizedBox(height: 80),
            InkWell(
              onTap: () async {
                try {
                  await LoginService.signInWithGoogle();
                  context.go('/good_morning');
                } catch (e) {
                  print('로그인 실패: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그인에 실패했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Image.asset('assets/images/google_login.png', width: 300),
            ),
          ],
        ),
      ),
    );
  }
}
