import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/pages/future_trip_page.dart';
import 'package:flutter/material.dart';

class FutureTripListTile extends StatelessWidget {
  final FutureTrip? futureTrip;
  final RideRequest? rideRequest;
  const FutureTripListTile({super.key, this.futureTrip, this.rideRequest});

  @override
  Widget build(BuildContext context) {
    return futureTrip != null
        ? futureTripList(context)
        : rideRequestList(context);
  }

  // Display the future trip for the driver
  ListTile futureTripList(BuildContext context) {
    return ListTile(
      title: Text("Your Trip to ${futureTrip!.destination}"),
      trailing: const Icon(Icons.money),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FutureTripPage(
          trip: futureTrip!,
        );
      })),
    );
  }

  // Display a future trip for a rider
  ListTile rideRequestList(BuildContext context) {
    return ListTile(
      title: Text(
          "${rideRequest!.futureTrip!.driver?.name}'s Trip to ${rideRequest!.futureTrip!.destination}"),
      trailing: const Icon(Icons.car_rental),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FutureTripPage(
          rideRequest: rideRequest,
        );
      })),
    );
  }
}
