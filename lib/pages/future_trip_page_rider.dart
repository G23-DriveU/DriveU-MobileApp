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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text("Picked Up 🚗", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Cancel ❌", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
            ListTile(
              title: Text("Driver: \n${widget.request.futureTrip?.driver?.name ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            ListTile(
              title: Text("Driver Rating: \n${widget.request.futureTrip?.driver?.driverRating ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // Trip Locations
            ListTile(
              title: Text("Start Location: \n${widget.request.futureTrip?.startLocation ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            ListTile(
              title: Text("Destination: \n${widget.request.futureTrip?.destination ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            ListTile(
              title: Text("Pickup Location: \n${widget.request.riderLocation ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // Estimated Times
            ListTile(
              title: Text("Estimated Pickup Time: \n${widget.request.pickupTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.pickupTime! * 1000).toString() : 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            ListTile(
              title: Text("Estimated Dropoff Time: \n${widget.request.dropoffTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.dropoffTime! * 1000).toString() : 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // Car Information
            ListTile(
              title: Text("Car: \n${widget.request.futureTrip?.driver?.name ?? 'N/A'} will be driving a ${widget.request.futureTrip?.driver?.carColor ?? 'N/A'} ${widget.request.futureTrip?.driver?.carMake ?? 'N/A'} ${widget.request.futureTrip?.driver?.carModel ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // Cost and Distance
            ListTile(
              title: Text("Cost: \n\$${widget.request.riderCost.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            ListTile(
              title: Text("Distance: \n${widget.request.distance.toStringAsFixed(2)} mi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
