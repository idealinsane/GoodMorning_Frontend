import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:good_morning/layout/default_layout.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('구글 로그인이 취소되었습니다');
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // 토큰 검증 함수 (백엔드에서는 DB 저장 없이 토큰만 검증)
  Future<Map<String, dynamic>> verifyTokenWithBackend(UserCredential userCredential) async {
    try {
      // ID 토큰 가져오기
      String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('ID 토큰이 null입니다');
      }
      
      // protected-endpoint 사용 (이미 POST 메서드 지원)
      final url = 'http://10.0.2.2:9090/auth/protected-endpoint';
      
      print('Verifying token with backend: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      
      print('Token verification status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Verification error: ${response.body}');
        throw Exception('토큰 검증 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during token verification: $e');
      rethrow;
    }
  }

  // 사용자 프로필 정보 가져오기 함수
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      // Firebase에서 ID 토큰 가져오기
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('ID 토큰이 null입니다');
      }
      
      print('Getting user profile with token...');
      
      // API 엔드포인트 (안드로이드 에뮬레이터용)
      final url = 'http://10.0.2.2:9090/api/users/me';
      
      // 요청 보내기
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      
      print('User profile response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        print('Received profile: $profileData');
        return profileData;
      } else {
        throw Exception('프로필 조회 실패: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Good Morning', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          
          // 구글 로그인 버튼
          InkWell(
            onTap: () async {
              try {
                // 1. Firebase로 구글 로그인 (프런트엔드에서 처리)
                final userCredential = await signInWithGoogle();
                print('Google Sign In successful: ${userCredential.user?.email}');
                
                // 2. 백엔드에 토큰 검증 요청 (DB 저장 없음)
                try {
                  final verificationResult = await verifyTokenWithBackend(userCredential);
                  print('Token verified: $verificationResult');
                  
                  // 3. 사용자 정보 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그인 성공: ${verificationResult["email"]}')),
                  );
                } catch (e) {
                  print('Token verification failed: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('토큰 검증 실패: $e')),
                  );
                }
              } catch (e) {
                print('Login error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그인 실패: $e')),
                );
              }
            },
            child: Image.asset('assets/images/google_login.png', width: 200),
          ),
          
          SizedBox(height: 20),
          
          // 프로필 정보 가져오기 버튼
          ElevatedButton(
            onPressed: () async {
              try {
                // 로그인 여부 확인
                if (FirebaseAuth.instance.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('먼저 로그인해주세요')),
                  );
                  return;
                }
                
                // 프로필 정보 가져오기
                final profileData = await getUserProfile();
                
                // 결과 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('프로필 정보: ${profileData.toString().substring(0, 100)}...')),
                );
              } catch (e) {
                print('Error fetching profile: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('프로필 정보 가져오기 실패: $e')),
                );
              }
            },
            child: Text('프로필 정보 가져오기'),
          ),
        ],
      ),
    );
  }
}
