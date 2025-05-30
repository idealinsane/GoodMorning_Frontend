import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String _tokenKey = 'auth_token';
  static String? _currentToken;

  static String? get currentToken => _currentToken;

  static Future<void> saveToken(String token) async {
    _currentToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);

    if (savedToken != null) {
      _currentToken = savedToken;
    } else {
      // 저장된 토큰이 없으면 Firebase 토큰 사용
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final token = await user.getIdToken();
          if (token != null) {
            _currentToken = token;
            await prefs.setString(_tokenKey, token);
          }
        } catch (e) {
          print('Firebase 토큰 가져오기 실패: $e');
        }
      }
    }
  }

  static Future<void> clearToken() async {
    _currentToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_currentToken != null) 'Authorization': 'Bearer $_currentToken',
    };
  }

  static Future<http.Response> logout() async {
    final response = await http.post(
      Uri.parse('http://goodmorningkr01.duckdns.org/auth/logout'),
      headers: getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      await clearToken();
    }

    return response;
  }

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

    await FirebaseAuth.instance.signInWithCredential(credential);
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    await saveToken(token!);

    // firebase auth token을 우리 서버로 보내서 200 응답 받기
    // 로컬 서버 Ip 아이폰 용: 192.168.0.100
    // path: /login

    final response = await http.post(
      Uri.parse('http://goodmorningkr01.duckdns.org/api/auth/sync'),
      headers: getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      // toast 띄우기
      Fluttertoast.showToast(msg: '로그인 성공');
    } else {
      Fluttertoast.showToast(msg: '로그인 실패 ${response.statusCode}');
      print(response.body);
    }

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
