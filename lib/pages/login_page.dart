import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: Place some logo or image here
          const Text("Login Page"),
          ElevatedButton(onPressed: () {}, child: const Text("Login")),
          Row(
            children: [
              const Text("Don't have an Account? "),
              GestureDetector(
                onTap: () {},
                child: const Text("Join"),
              ),
              const Text(" DriveU-nation for FREE")
            ],
          )
        ],
      ))),
    );
  }
}
