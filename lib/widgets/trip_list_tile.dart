import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:flutter/material.dart';

class TripListTile extends StatelessWidget {
  final FutureTrip? futureTrip;
  final PastTrip? pastTrip;
  const TripListTile({super.key, this.futureTrip, this.pastTrip});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          Text("${pastTrip!.driver.name}'s Trip to ${pastTrip!.destination}"),
      trailing: const Icon(Icons.car_rental),
    );
  }
}
