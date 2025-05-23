import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:good_morning/layout/default_layout.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
          Text('Good Morning'),
          // ElevatedButton(
          //   onPressed: signInWithGoogle,
          //   child: Text('Google Sign In'),
          // ),
          InkWell(
            onTap: () async {
              UserCredential userCredential = await signInWithGoogle();
              print(userCredential.user?.email);
            },
            child: Image.asset('assets/images/google_login.png', width: 200),
          ),
        ],
      ),
    );
  }
}
