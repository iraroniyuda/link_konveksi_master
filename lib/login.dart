// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:link_konveksi_master/home_screen.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        // Handle successful login here.
        if (user != null) {
          return user;
        }
      }
    } catch (e) {
      // Handle login errors here (e.g., display an error message).
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo Image (centered at 40% from the top)
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
              child: Image.asset(
                'assets/ic_launcher.png', // Replace with your image path
                width: 150, // Adjust the width as needed
                height: 150, // Adjust the height as needed
              ),
            ),

            // Google Sign-In Button (centered at 25% from the bottom)
            Container(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.15),
              child: ElevatedButton(
                onPressed: () async {
                  final User? user = await _signInWithGoogle(context);
                  if (user != null) {
                    // Redirect to the home screen or perform other actions on successful login.
                    // For example, you can use Navigator to navigate to the home screen.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Login Google'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
