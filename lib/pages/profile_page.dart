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
            const ListTile(
              title: Text("Your Info"),
            ),
            Text("${FirebaseAuth.instance.currentUser?.email}"),
            // TODO: Change to Image.network to display images hosted on the server
            const Image(
              // TODO: idk how best to store this so we don't make eronius api calls and
              image: AssetImage('assets/images/knightro.bmp'),
              width: 150,
              height: 150,
            ),
            const Text("Name"),
            Text(SingleUser().getUser()!.name),
            const Text("Phone"),
            Text(SingleUser().getUser()!.phoneNumber),
            const Text("Email"),
            Text(SingleUser().getUser()!.email),
            const ListTile(
              title: Text("Your Car"),
            ),
            SingleUser().getUser()?.driver == true
                ? Column(
                    children: [
                      const Text("Make"),
                      Text(SingleUser().getUser()!.carMake!),
                      const Text("Model"),
                      Text(SingleUser().getUser()!.carModel!),
                      const Text("Plate Number"),
                      Text(SingleUser().getUser()!.carPlate!),
                      const Text("Color"),
                      Text(SingleUser().getUser()!.carColor!),
                    ],
                  )
                : const Text("You don't have a car on file"),
            // TODO: should be at bottom
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
