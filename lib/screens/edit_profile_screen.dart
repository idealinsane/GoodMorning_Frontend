import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/layout/default_layout.dart';
import 'package:good_morning/models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    final profile = UserProfile.fromFirebaseUser(user);
    _nicknameController = TextEditingController(text: profile.nickname);
    _bioController = TextEditingController(text: profile.bio ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    user.updateDisplayName(_nicknameController.text);
    // user.updateProfile(
    //   displayName: _nicknameController.text,
    //   photoURL: _bioController.text,
    // );
    // // user.updatePhotoURL( _bioController.text);

    context.pop(); // 저장 후 이전 화면으로
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(title: const Text('Edit Profile'), actions: [
        
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
              ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
