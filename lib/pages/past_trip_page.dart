import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

// Used to display trips for Drivers using the application
// TODO: Display all of the info for the trip in a nice way
// Make sure to delinate between rider and driver here
class PastTripPage extends StatefulWidget {
  final PastTrip trip;
  final LocationData? userPosition;
  const PastTripPage(
      {super.key, required this.trip, required this.userPosition});

  @override
  State<PastTripPage> createState() => _PastTripPageState();
}

class _PastTripPageState extends State<PastTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Start Location: ${widget.trip.startLocation}"),
          Text("Destination: ${widget.trip.destination}"),
          // Add more details as needed
          ImageFrame(firebaseUid: FirebaseAuth.instance.currentUser!.uid),
          Text("Destination: ${widget.trip.destination}"),
          Text(
              "Driver: ${widget.trip.driver?.name ?? SingleUser().getUser()!.name}"),
          Text(
              "Car: ${"${widget.trip.driver?.carMake ?? SingleUser().getUser()!.carMake} ${widget.trip.driver?.carModel ?? SingleUser().getUser()!.carModel}"}"),
// Display driver specific information about the trip
          if (widget.trip.driverId == SingleUser().getUser()!.id)
            Column(
              children: [
                Text("You made \$${widget.trip.driverPayout}"),
                Row(
                  children: [
                    Text("You Drove"),
                    ImageFrame(firebaseUid: widget.trip.rider!.firebaseUid!)
                  ],
                )
              ],
            ),
          if (widget.trip.driverId != SingleUser().getUser()!.id)
            Text("This ride cost you ${widget.trip.riderCost}")
        ],
      ),
    );
  }
}
