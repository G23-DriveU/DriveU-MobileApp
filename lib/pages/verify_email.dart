import 'dart:async';

import 'package:driveu_mobile_app/pages/home_page.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// TODO: Ability to recheck the email verification status and allow user to resend the email if they want
// Can we customize the email?
class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  // TODO: We can use this timer to recheck the email verification status
  Timer? _timer;
  // Call Firebase to send the email verification
  Future _sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  bool checkEmailVerification() {
    return FirebaseAuth.instance.currentUser!.emailVerified;
  }

  @override
  void initState() {
    super.initState();
    // Send the email verification
    if (!checkEmailVerification()) {
      _sendEmailVerification();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser!.emailVerified
        ? const HomePage()
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Please verify your email address.\nAn email has been sent to ${FirebaseAuth.instance.currentUser?.email}"),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () => AuthService().signOut(),
                      child: const Text('Cancel'))
                ],
              ),
            ),
          );
  }
}
