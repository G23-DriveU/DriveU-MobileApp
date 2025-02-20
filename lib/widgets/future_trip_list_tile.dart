import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/pages/future_trip_page.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:flutter/material.dart';

class FutureTripListTile extends StatelessWidget {
  final FutureTrip futureTrip;
  const FutureTripListTile({super.key, required this.futureTrip});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          "${futureTrip.driver?.name ?? "Your Trip"} to ${futureTrip.destination}"),
      trailing: futureTrip.driverId == SingleUser().getUser()!.id
          ? const Icon(Icons.money)
          : const Icon(Icons.car_rental),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FutureTripPage(
          trip: futureTrip,
          userPosition: null,
        );
      })),
    );
  }
}
