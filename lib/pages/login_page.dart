import 'package:driveu_mobile_app/widgets/login_form.dart';
import 'package:driveu_mobile_app/widgets/register_form_firebase.dart';
import 'package:flutter/material.dart';

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
          const Text("Welcome to DriveU!"),
          // Form which takes in user credentials and then logs them in
          const LoginForm(),
          Row(
            children: [
              const Text("Don't have an Account? "),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const RegisterFormFirebase();
                  }));
                },
                child: const Text("Join"),
              ),
              const Text(" DriveU-nation for FREE!")
            ],
          )
        ],
      ))),
    );
  }
}
