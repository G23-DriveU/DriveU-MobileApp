import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:location/location.dart';

// Used to display trips for Drivers using the application
// TODO: Display all of the info for the trip in a nice way
// Make sure to delineate between rider and driver here
class PastTripPage extends StatefulWidget {
  final PastTrip trip;
  final LocationData? userPosition;
  const PastTripPage(
      {super.key, required this.trip, required this.userPosition});

  @override
  State<PastTripPage> createState() => _PastTripPageState();
}

class _PastTripPageState extends State<PastTripPage> {
  double _rating = 3;
  late PastTrip trip;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
  }

  // Determine if user can rate
  bool _isRated() {
    // User is the rider
    if (SingleUser().getUser()!.id != trip.driverId) {
      return trip.driverRated;
    }
    // User is the driver
    else {
      return trip.riderRated;
    }
  }

  void _rateUserDialog(BuildContext context, PastTrip trip) {
    String rateeName = SingleUser().getUser()!.id == trip.driverId
        ? trip.rider!.name
        : trip.driver!.name;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Center(child: Text("Rate $rateeName")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StarRating(
                    rating: _rating,
                    onRatingChanged: (rating) {
                      // Like setState but just for the dialog
                      setDialogState(() {
                        _rating =
                            rating; // Update the rating in the dialog's state
                      });
                    },
                  ),
                  Text("Rating $_rating")
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Who are we rating
                    String ratee = SingleUser().getUser()!.id == trip.driverId
                        ? "rider"
                        : "driver";
                    // The ratee (the one getting rated) id
                    late int rateeId;
                    if (ratee == "driver") {
                      rateeId = trip.driverId;
                    } else {
                      rateeId = trip.riderId;
                    }

                    // Handle the rating submission logic here
                    int res = await TripApi().rateUser({
                      "${ratee}Id": rateeId.toString(),
                      "rating": _rating.toString(),
                      "tripId": trip.id.toString()
                    }, ratee);

                    if (res == 200) {
                      setState(() {
                        if (ratee == "driver") {
                          trip.riderRated = true;
                        } else {
                          trip.driverRated = true;
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            onPressed: _isRated() == false
                ? () => _rateUserDialog(context, trip)
                : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Theme.of(context).disabledColor,
            ),
            child: const Text("Rate"),
          ),
        )
      ],
      body: Column(
        children: [
          Text("Start Location: ${trip.startLocation}"),
          Text("Destination: ${trip.destination}"),
          // Add more details as needed
          ImageFrame(firebaseUid: FirebaseAuth.instance.currentUser!.uid),
          Text("Destination: ${trip.destination}"),
          Text("Driver: ${trip.driver?.name ?? SingleUser().getUser()!.name}"),
          Text(
              "Car: ${"${trip.driver?.carMake ?? SingleUser().getUser()!.carMake} ${trip.driver?.carModel ?? SingleUser().getUser()!.carModel}"}"),
          // Display driver specific information about the trip
          if (trip.driverId == SingleUser().getUser()!.id)
            Column(
              children: [
                Text("You made \$${trip.driverPayout}"),
                Row(
                  children: [
                    Text("You Drove"),
                    ImageFrame(firebaseUid: trip.rider!.firebaseUid!)
                  ],
                )
              ],
            ),
          if (trip.driverId != SingleUser().getUser()!.id)
            Text("This ride cost you ${trip.riderCost}")
        ],
      ),
    );
  }
}
