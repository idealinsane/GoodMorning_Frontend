import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:good_morning/models/user_profile.dart';

class UserService {
  static const String _baseUrl = 'http://localhost:9090/api/users';

  /// 사용자 프로필을 조회합니다.
  ///
  /// [uid] 조회할 사용자의 Firebase UID
  /// [token] Firebase 인증 토큰
  ///
  /// Returns [UserProfile] if successful
  /// Throws [Exception] if the request fails
  static Future<UserProfile> getUserProfile(String uid, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/profile/$uid'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromMap(data);
    } else if (response.statusCode == 404) {
      throw UserNotFoundException('사용자를 찾을 수 없습니다.');
    } else {
      throw Exception('프로필 조회 실패: ${response.statusCode}');
    }
  }

  /// 현재 로그인한 사용자의 프로필을 조회합니다.
  ///
  /// Returns [UserProfile] if successful
  /// Throws [Exception] if the request fails or user is not logged in
  static Future<UserProfile> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    try {
      final token = await user.getIdToken();
      return await getUserProfile(user.uid, token!);
    } catch (e) {
      // 서버 요청 실패 시 Firebase 정보만 사용
      return UserProfile.fromFirebaseUser(user);
    }
  }

  /// 사용자 프로필을 업데이트합니다.
  ///
  /// [bio] 업데이트할 소개글
  /// [nickname] 업데이트할 닉네임
  /// Returns [UserProfile] if successful
  /// Throws [Exception] if the request fails
  static Future<UserProfile> updateProfile({
    String? bio,
    String? nickname,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final token = await user.getIdToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'bio': bio, 'nickname': nickname}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromMap(data);
    } else {
      throw Exception('프로필 업데이트 실패: ${response.statusCode}');
    }
  }
}

class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException(this.message);

  @override
  String toString() => message;
}
