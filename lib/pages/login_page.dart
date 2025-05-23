import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:good_morning/layout/default_layout.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:good_morning/pages/user_page.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  Future<UserCredential> signInWithGoogle() async {
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

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Column(
        children: [
          Text('Good Morning!'),
          // ElevatedButton(
          //   onPressed: signInWithGoogle,
          //   child: Text('Google Sign In'),
          // ),
          InkWell(
            onTap: () async {
              UserCredential userCredential = await signInWithGoogle();
              final user = userCredential.user;

              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPage(
                      name: user.displayName ?? 'No Name',
                      email: user.email ?? 'No Email',
                      profileImageUrl: user.photoURL ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그인에 실패했습니다.')),
                );
              }
            },
            child: Image.asset('assets/images/google_login.png', width: 200),
          ),
        ],
      ),
    );
  }
}
