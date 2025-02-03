import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FutureTripListTile extends StatelessWidget {
  final FutureTrip? futureTrip;
  const FutureTripListTile({super.key, required this.futureTrip});

  // When you click on the ListTile, give more detailed information
  void showTripInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("${futureTrip!.driver?.name}'s Trip"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageFrame(firebaseUid: FirebaseAuth.instance.currentUser!.uid),
              Text("Destination: ${futureTrip!.destination}"),
              Text("Driver: ${futureTrip!.driver?.name}"),
              Text(
                  "Car: ${"${futureTrip!.driver?.carMake!} ${futureTrip!.driver?.carModel}"}"),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          "${futureTrip!.driver?.name}'s Trip to ${futureTrip!.destination}"),
      trailing: futureTrip!.driverId == SingleUser().getUser()!.id
          ? const Icon(Icons.money)
          : const Icon(Icons.car_rental),
      onTap: () => showTripInfo(context),
    );
  }
}
