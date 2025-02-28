import 'dart:async';
import 'package:driveu_mobile_app/model/app_user.dart';
import 'package:driveu_mobile_app/pages/home_page.dart';
import 'package:driveu_mobile_app/services/api/user_api.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// TODO: Actually fix the resend email verifcation email
class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  Timer? timer;
  bool canResend = false;
  bool isEmailVerified = false;
  bool isLoading = false;

  Future sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    setState(() {
      canResend = false;
    });
  }

  Future checkEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      _loadUser();
    }
  }

  void _loadUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      AppUser? user = await UserApi.getUser({
        'firebaseUid': FirebaseAuth.instance.currentUser!.uid,
        'fcmToken': fcmToken ?? ""
      });
      if (user != null) {
        setState(() {
          SingleUser().setUser(user);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Kick the user back to the login screen
        AuthService().signOut();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendEmailVerification();
      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerification());
    } else {
      _loadUser();
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : isEmailVerified
                ? const HomePage()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Please verify your email address.\nAn email has been sent to ${FirebaseAuth.instance.currentUser?.email}"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: canResend ? sendEmailVerification : null,
                        child: const Text("Resend Email"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
