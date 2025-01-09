import 'package:driveu_mobile_app/pages/login_page.dart';
import 'package:driveu_mobile_app/pages/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const VerifyEmail();
            }
            // The user doesn't exist, show the login page.
            else {
              return const LoginPage();
            }
          }),
    );
  }
}
