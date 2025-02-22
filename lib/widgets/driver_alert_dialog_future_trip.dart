import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

// Used to display trips for Drivers using the application
class DriverAlertDialogFutureTrip extends StatefulWidget {
  final FutureTrip trip;
  final LocationData? userPosition;
  const DriverAlertDialogFutureTrip(
      {super.key, required this.trip, required this.userPosition});

  @override
  State<DriverAlertDialogFutureTrip> createState() =>
      _DriverAlertDialogFutureTripState();
}

class _DriverAlertDialogFutureTripState
    extends State<DriverAlertDialogFutureTrip> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Your Trip to ${widget.trip.destination}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Destination: ${widget.trip.destination}"),
          Text("Start Location: ${widget.trip.startLocation}"),
          // Add more details as needed
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          // TODO: this will change based on if rider or driver
          onPressed: () async {},
          child: const Text('Start'),
        ),
      ],
    );
  }
}
