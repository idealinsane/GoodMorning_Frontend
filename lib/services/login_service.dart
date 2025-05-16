import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginService {
  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // firebase auth token을 우리 서버로 보내서 200 응답 받기
    // 로컬 서버 Ip 아이폰 용: 192.168.0.100
    // path: /login

    // final response = await http.post(
    //   Uri.parse('http://localhost:9090/login'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'token': credential.accessToken}),
    // );

    // if (response.statusCode == 200) {
    //   // toast 띄우기
    //   Fluttertoast.showToast(msg: '로그인 성공');
    // } else {
    //   Fluttertoast.showToast(msg: '로그인 실패');
    // }

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
