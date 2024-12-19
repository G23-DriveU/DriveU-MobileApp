import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("${FirebaseAuth.instance.currentUser?.email}"),
            const Image(
              // TODO: idk how best to store this so we don't make eronius api calls and
              image: AssetImage('assets/images/JacobTBPsmall.jpg'),
              width: 200,
              height: 200,
            ),
            const Text("Name"),
            const Text("Phone"),
            const Text("Email")
          ],
        ),
      ),
    );
  }
}
