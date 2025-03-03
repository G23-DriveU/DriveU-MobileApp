import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:flutter/material.dart';

class FutureTripPageRider extends StatefulWidget {
  final RideRequest request;
  const FutureTripPageRider({super.key, required this.request});

  @override
  State<FutureTripPageRider> createState() => _FutureTripPageRiderState();
}

class _FutureTripPageRiderState extends State<FutureTripPageRider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            onPressed: () {},
            child: Text("Picked Up 🚗", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        )
      ],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Driver Image
            Center(
              child: ClipOval(
                child: Container(
                  width: 120,
                  height: 120,
                  child: ImageFrame(
                    firebaseUid: widget.request.futureTrip?.driver?.firebaseUid ?? '',
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Driver Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🧑‍🦰 Driver: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${widget.request.futureTrip?.driver?.name ?? 'N/A'}"),
              ],
            ),
            SizedBox(height: 8),
            Text("⭐ Driver Rating: ${widget.request.futureTrip?.driver?.driverRating ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            // Trip Locations
            Text("📍 Start Location: ${widget.request.futureTrip?.startLocation ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("🏁 Destination: ${widget.request.futureTrip?.destination ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("📍 Pickup Location: ${widget.request.riderLocation ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            // Estimated Times
            Text(
              "⏰ Estimated Pickup Time: ${widget.request.pickupTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.pickupTime! * 1000).toString() : 'N/A'}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "⏰ Estimated Dropoff Time: ${widget.request.dropoffTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.dropoffTime! * 1000).toString() : 'N/A'}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Car Information
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🚗 Car: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "${widget.request.futureTrip?.driver?.name ?? 'N/A'} will be driving a ${widget.request.futureTrip?.driver?.carColor ?? 'N/A'} ${widget.request.futureTrip?.driver?.carMake ?? 'N/A'} ${widget.request.futureTrip?.driver?.carModel ?? 'N/A'}",
                ),
              ],
            ),
            SizedBox(height: 12),

            // Cost and Distance
            Text("💰 Cost: \$${widget.request.riderCost.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("📏 Distance: ${widget.request.distance.toStringAsFixed(2)} mi", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
