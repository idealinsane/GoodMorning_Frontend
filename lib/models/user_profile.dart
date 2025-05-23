import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String uid;
  final String nickname;
  final String? bio;
  final String? profileImageUrl;
  int likes;

  UserProfile({
    required this.uid,
    required this.nickname,
    this.bio,
    this.profileImageUrl,
    this.likes = 0,
  });

  // Factory constructor to create a UserProfile from a map
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] as String,
      nickname: data['nickname'] as String,
      bio: data['bio'] as String?,
      profileImageUrl:
          data['profileImageUrl'] as String? ??
          data['profile_picture'] as String?,
      likes: data['likes'] as int? ?? 0,
    );
  }

  // Method to convert a UserProfile to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'likes': likes,
    };
  }

  // UserProfile from FirebaseAuth User
  factory UserProfile.fromFirebaseUser(User user, {String? bio}) {
    return UserProfile(
      uid: user.uid,
      nickname: user.displayName ?? '',
      profileImageUrl: user.photoURL,
      bio: bio,
      likes: 0,
    );
  }

  /// Creates a copy of this UserProfile with the given fields replaced with the new values.
  UserProfile copyWith({
    String? uid,
    String? nickname,
    String? bio,
    String? profileImageUrl,
    int? likes,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      likes: likes ?? this.likes,
    );
  }

  @override
  String toString() {
    return 'UserProfile{uid: $uid, nickname: $nickname, bio: $bio, profileImageUrl: $profileImageUrl, likes: $likes}';
  }
}
