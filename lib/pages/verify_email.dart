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
  Timer? timer;
  // Keep track of when the 'resend' button can be clicked
  bool canResend = false;
  // Has the users email been verified?
  bool isEmailVerified = false;
  // Call Firebase to send the email verification
  Future sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    // User can't resend the email until the timer is done
    setState(() {
      canResend = false;
    });
  }

  // Check the current verification status
  Future checkEmailVerification() async {
    // Reload the user since the email verification status may have changed
    await FirebaseAuth.instance.currentUser?.reload();
    // Update the flag
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    // Send the email verification
    if (!isEmailVerified) {
      sendEmailVerification();

      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerification());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser!.emailVerified
        ? HomePage()
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
                    onPressed: canResend ? sendEmailVerification : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          canResend ? Colors.white : Colors.black54,
                      backgroundColor: canResend
                          ? Theme.of(context).primaryColor
                          : Colors.grey, // Text color
                    ),
                    child: const Text("Send Verification Again"),
                  ),
                  ElevatedButton(
                      onPressed: AuthService().signOut,
                      child: const Text("Sign out"))
                ],
              ),
            ),
          );
  }
}
