import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/services/api/pay_pal_api.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/pay_pal_webview.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class RiderAlertDialogFutureTrip extends StatefulWidget {
  final FutureTrip trip;
  final LocationData? userPosition;
  const RiderAlertDialogFutureTrip(
      {super.key, required this.trip, required this.userPosition});

  @override
  State<RiderAlertDialogFutureTrip> createState() =>
      _RiderAlertDialogFutureTrip();
}

class _RiderAlertDialogFutureTrip extends State<RiderAlertDialogFutureTrip> {
  bool _isMounted = true;

  @override
  void dispose() {
    _isMounted = false;
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);
    return AlertDialog(
      title: Text("${widget.trip.driver!.name}'s Trip"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Destination: ${widget.trip.destination}"),
          Text("Start Location: ${widget.trip.startLocation}"),
          Text("Driver: ${widget.trip.driver!.name}"),
          Text(
              "Car: ${widget.trip.driver!.carMake} ${widget.trip.driver!.carModel}"),
          Text("Your Estimated Cost: ${widget.trip.request?.riderCost}")
          // Add more details as needed
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Communicate with PayPal
            final payUrl = await PayPalApi().getPayUrl({
              "tripCost": widget.trip.request!.riderCost.toStringAsFixed(2)
            });

            var authId;
            if (_isMounted) {
              // Rider must put in payment details for the ride
              authId = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PayPalWebView(url: payUrl),
                ),
              );
            }

            // We got an authId from the backend
            if (authId.runtimeType == String) {
              // Communicate with PostgreSQL
              await TripApi().createRideRequest({
                'futureTripId': widget.trip.id.toString(),
                'riderId': SingleUser().getUser()!.id!.toString(),
                'riderLat': mapState.startLocation.latitude.toString(),
                'riderLng': mapState.startLocation.longitude.toString(),
                'roundTrip': mapState.wantRoundTrip.toString(),
                'authorizationId': authId.toString()
              });
              // Request was successful
              Navigator.of(context).pop();
              print("Successfull Request made");
            } else {
              print("Failed to get PayPal credentials, canceling transaction");
            }
          },
          child: const Text('Join Ride'),
        ),
      ],
    );
  }
}
