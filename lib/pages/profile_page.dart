import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
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
              image: AssetImage('assets/images/knightro.bmp'),
              width: 200,
              height: 200,
            ),
            const Text("Name"),
            Text(SingleUser().getUser()!.name),
            const Text("Phone"),
            Text(SingleUser().getUser()!.phoneNumber),
            const Text("Email"),
            Text(SingleUser().getUser()!.email),
            ElevatedButton(
              onPressed: () => AuthService().signOut(),
              child: const Text("Sign Out"),
            )
          ],
        ),
      ),
    );
  }
}
