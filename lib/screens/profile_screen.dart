import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }
    UserProfile user = UserProfile.fromFirebaseUser(
      FirebaseAuth.instance.currentUser!,
    );

    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 200,
              color: Colors.grey[400], // background placeholder
            ),
            const SizedBox(height: 80), // space for profile image
            Text(
              user.nickname,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.bio ?? 'A mantra goes here',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var emoji in ['👍', '❤️', '🥰', '😆', '😮'])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
                FirebaseAuth.instance.signOut();
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
        Positioned(
          top: 140,
          left: MediaQuery.of(context).size.width / 2 - 60,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 56,
              backgroundImage:
                  user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
              child:
                  user.profileImageUrl == null
                      ? const Icon(Icons.person, size: 56)
                      : null,
            ),
          ),
        ),
        // Edit button with FAB icon
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () {
              // Navigate to edit profile screen
              context.go('/profile/edit');
            },
            child: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }
}
