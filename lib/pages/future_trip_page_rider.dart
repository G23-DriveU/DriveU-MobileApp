import 'package:driveu_mobile_app/helpers/helpers.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:flutter/material.dart';

class FutureTripPageRider extends StatefulWidget {
  RideRequest request;
  FutureTripPageRider({super.key, required this.request});

  @override
  State<FutureTripPageRider> createState() => _FutureTripPageRiderState();
}

class _FutureTripPageRiderState extends State<FutureTripPageRider> {
  // Reports to the API that the rider has been picked up by the driver
  Future<void> pickedUp() async {
    await TripApi().pickUpRider({
      "rideRequestId": widget.request.id.toString(),
      "pickupTime": getSecondsSinceEpoch().toString()
    });
  }

  // Used in tandem with the 'RefreshIndicator' to get updated
  // trip details when looking at a specific trip.
  Future<void> _refreshTrip() async {
    // Fetch the updated trip information
    FutureTrip? updatedTrip = await TripApi().getFutureTrip(
        {'futureTripId': widget.request.futureTripId.toString()});

    if (updatedTrip != null) {
      setState(() {
        widget.request = updatedTrip.request!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  widget.request.status == 'started' ? () => pickedUp() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.request.status == 'started'
                    ? Colors.blue
                    : Colors.grey,
              ),
              child: Text(
                "Picked Up 🚗",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        )
      ],
      body: RefreshIndicator(
        onRefresh: _refreshTrip,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Driver Image
              Center(
                child: ClipOval(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: ImageFrame(
                      firebaseUid:
                          widget.request.futureTrip?.driver?.firebaseUid ?? '',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Driver Info
              ListTile(
                title: Text(
                    "Driver: \n${widget.request.futureTrip?.driver?.name ?? 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              ListTile(
                title: Text(
                    "Driver Rating: \n${widget.request.futureTrip?.driver?.driverRating ?? 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // Trip Locations
              ListTile(
                title: Text(
                    "Start Location: \n${widget.request.futureTrip?.startLocation ?? 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              ListTile(
                title: Text(
                    "Destination: \n${widget.request.futureTrip?.destination ?? 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              ListTile(
                title: Text(
                    "Pickup Location: \n${widget.request.riderLocation ?? 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // Estimated Times
              ListTile(
                title: Text(
                    "Estimated Pickup Time: \n${widget.request.pickupTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.pickupTime! * 1000).toString() : 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              ListTile(
                title: Text(
                    "Estimated Dropoff Time: \n${widget.request.dropoffTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.dropoffTime! * 1000).toString() : 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // Car Information
              ListTile(
                title: Text(
                    "Car: \n${widget.request.futureTrip?.driver?.name ?? 'N/A'} will be driving a ${widget.request.futureTrip?.driver?.carColor ?? 'N/A'} ${widget.request.futureTrip?.driver?.carMake ?? 'N/A'} ${widget.request.futureTrip?.driver?.carModel ?? 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // Cost and Distance
              ListTile(
                title: Text(
                    "Cost: \n\$${widget.request.riderCost.toStringAsFixed(2)}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              ListTile(
                title: Text(
                    "Distance: \n${widget.request.distance.toStringAsFixed(2)} mi",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
