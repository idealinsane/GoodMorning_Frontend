import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:good_morning/layout/default_layout.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:good_morning/pages/user_page.dart';

class UserPage extends StatelessWidget {
  final String name;
  final String email;
  final String profileImageUrl;

  const UserPage({
    Key? key,
    required this.name,
    required this.email,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 로그아웃 또는 설정 페이지로 이동 등의 기능 추가 가능
              },
              child: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
