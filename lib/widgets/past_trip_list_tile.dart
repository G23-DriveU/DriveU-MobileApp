import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/pages/past_trip_page.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:flutter/material.dart';

class PastTripListTile extends StatelessWidget {
  final PastTrip pastTrip;
  const PastTripListTile({super.key, required this.pastTrip});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          "${pastTrip.driver?.name ?? "Your"} Trip to ${pastTrip.destination}"),
      trailing: pastTrip.driverId == SingleUser().getUser()!.id
          ? const Icon(Icons.money)
          : const Icon(Icons.car_rental),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PastTripPage(
          trip: pastTrip,
          userPosition: null,
        );
      })),
    );
  }
}
