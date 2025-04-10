import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String uid;
  final String nickname;
  final String? bio;
  final String? profileImageUrl;

  UserProfile({
    required this.uid,
    required this.nickname,
    this.bio,
    this.profileImageUrl,
  });

  // Factory constructor to create a UserProfile from a map
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] as String,
      nickname: data['nickname'] as String,
      bio: data['bio'] as String,
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }

  // Method to convert a UserProfile to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
    };
  }

  // UserProfile from FirebaseAuth User
  factory UserProfile.fromFirebaseUser(User user) {
    return UserProfile(
      uid: user.uid,
      nickname: user.displayName ?? '',

      profileImageUrl: user.photoURL,
    );
  }
  @override
  String toString() {
    return 'UserProfile{uid: $uid, nickname: $nickname, bio: $bio, profileImageUrl: $profileImageUrl}';
  }
}
