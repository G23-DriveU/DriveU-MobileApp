import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

// Used to display trips for Drivers using the application
class DriverAlertDialogFutureTrip extends StatefulWidget {
  final FutureTrip trip;
  final LocationData? userPosition;

  const DriverAlertDialogFutureTrip(
      {super.key, required this.trip, this.userPosition});

  @override
  State<DriverAlertDialogFutureTrip> createState() =>
      _DriverAlertDialogFutureTripState();
}

class _DriverAlertDialogFutureTripState
    extends State<DriverAlertDialogFutureTrip> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "🛣️ Your Trip to ${widget.trip.destination}",
        style: const TextStyle(),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
        children: [
          _infoRow("📍 Destination:", widget.trip.destination),
          _infoRow("📌 Start Location:", widget.trip.startLocation),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('❌ Close', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8), // Space between buttons
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // TODO: this will change based on if rider or driver
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('🚀 Start', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2), // Space between title and value
          Text(value ?? 'N/A', textAlign: TextAlign.left),
        ],
      ),
    );
  }
}
