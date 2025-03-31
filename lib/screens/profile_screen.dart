import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Profile'),
          //log out button
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              context.go('/login');
            },
            child: Text('Log Out'),
          ),
          // error page
          ElevatedButton(
            onPressed: () {
              context.go('/error');
            },
            child: Text('Go to Error'),
          ),
        ],
      ),
    );
  }
}
