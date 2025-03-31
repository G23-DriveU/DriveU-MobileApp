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
  
  const RiderAlertDialogFutureTrip({
    super.key, 
    required this.trip, 
    required this.userPosition
  });

  @override
  State<RiderAlertDialogFutureTrip> createState() => _RiderAlertDialogFutureTrip();
}

class _RiderAlertDialogFutureTrip extends State<RiderAlertDialogFutureTrip> {
  bool _isMounted = true;

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);
    
    return AlertDialog(
      title: Text(
        "🚗 ${widget.trip.driver!.name}'s Trip",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,  // Align left for clarity
        children: [
          _infoRow("📍 Destination:", widget.trip.destination),
          _infoRow("📌 Start Location:", widget.trip.startLocation),
          _infoRow("👨‍✈️ Driver:", widget.trip.driver!.name),
          _infoRow("🚘 Car:", "${widget.trip.driver!.carMake} ${widget.trip.driver!.carModel}"),
          _infoRow("💰 Estimated Cost:", "\$${widget.trip.request?.riderCost ?? 'N/A'}"),
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
                  final payUrl = await PayPalApi().getPayUrl({
                    "tripCost": widget.trip.request!.riderCost.toStringAsFixed(2)
                  });

                  var authId;
                  if (_isMounted) {
                    authId = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PayPalWebView(url: payUrl),
                      ),
                    );
                  }

                  if (authId.runtimeType == String) {
                    await TripApi().createRideRequest({
                      'futureTripId': widget.trip.id.toString(),
                      'riderId': SingleUser().getUser()!.id!.toString(),
                      'riderLat': mapState.startLocation.latitude.toString(),
                      'riderLng': mapState.startLocation.longitude.toString(),
                      'roundTrip': mapState.wantRoundTrip.toString(),
                      'authorizationId': authId.toString()
                    });

                    Navigator.of(context).pop();
                    print("✅ Successful Request Made");
                  } else {
                    print("⚠️ Failed to get PayPal credentials, canceling transaction");
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('🚖 Join Ride', style: TextStyle(fontSize: 16)),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(value ?? 'N/A', softWrap: true),
          ),
        ],
      ),
    );
  }
}
