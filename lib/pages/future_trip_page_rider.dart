import 'package:driveu_mobile_app/helpers/helpers.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/pages/rides_page.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:flutter/material.dart';

// Stateful widget to display future trip details for the rider
class FutureTripPageRider extends StatefulWidget {
  RideRequest request;
  TripStage stage;
  FutureTripPageRider({super.key, required this.request, required this.stage});

  @override
  State<FutureTripPageRider> createState() =>
      _FutureTripPageRiderState(); // Create state for the widget
}

// State class for FutureTripPageRider
class _FutureTripPageRiderState extends State<FutureTripPageRider> {
  // Reports to the API that the rider has been picked up by the driver
  Future<void> _pickedUp() async {
    await TripApi().pickUpRider({
      "rideRequestId": widget.request.id.toString(),
      "pickupTime": getSecondsSinceEpoch().toString()
    });
    setState(() {
      widget.stage = TripStage.pickedUp;
    });
  }

  Future<void> _droppedOff() async {
    await TripApi().dropOffRider({
      "futureTripId": widget.request.futureTripId.toString(),
      "dropOffTime": getSecondsSinceEpoch().toString(),
      "lat": "",
      "lng": ""
    });
    // No need to update trip state since it is done
  }

  // Used in tandem with the 'RefreshIndicator' to get updated
  // trip details when looking at a specific trip.
  Future<void> _refreshTrip() async {
    // Fetch the updated trip information
    FutureTrip? updatedTrip = await TripApi().getFutureTrip(
        {'futureTripId': widget.request.futureTripId.toString()});

    if (updatedTrip != null) {
      setState(() {
        // Only update if the request has been accepted
        widget.request = updatedTrip.request ?? widget.request;
        widget.stage = getTripStage(null, widget.request);
      });
    }
  }

  ElevatedButton tripStage(TripStage stage) {
    switch (stage) {
      case TripStage.notStarted:
      case TripStage.startedFirstLeg:
        return ElevatedButton(
          // 'Picked Up' button
          onPressed: widget.stage == TripStage.startedFirstLeg
              ? _pickedUp
              : null, // Currently empty onPressed callback for button functionality
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).disabledColor,
          ),
          child: Text("Picked Up",
              style: TextStyle(
                  color: widget.stage == TripStage.startedFirstLeg
                      ? Colors.white
                      : Colors.grey[700], // Adjust text color
                  fontWeight: FontWeight.bold)), // Button label with bold text
        );
      case TripStage.startSecondLeg:
        return ElevatedButton(
          // 'Picked Up' button
          onPressed:
              _droppedOff, // Currently empty onPressed callback for button functionality
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).disabledColor,
          ),
          child: Text(
            "Dropped Off",
          ), // Button label with bold text
        );
      default:
        return ElevatedButton(
          onPressed: null,
          child: Text("Picked Up",
              style: TextStyle(
                  color: Colors.grey[700], // Adjust text color
                  fontWeight: FontWeight.bold)), // Button label with bold text
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Trip status is ${widget.stage}\n");
    // Build method to define the widget tree
    return Scaffold(
      // Scaffold provides a page layout structure
      persistentFooterButtons: [
        // Footer buttons at the bottom of the page
        Row(
          // Row layout to arrange buttons horizontally
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly, // Space buttons evenly across the row
          children: [
            tripStage(widget.stage),
          ],
        )
      ],
      body: RefreshIndicator(
        onRefresh: _refreshTrip,
        child: Padding(
          // Add padding around the content
          padding: const EdgeInsets.all(16.0), // 16px padding on all sides
          child: ListView(
            // ListView allows content to be scrollable
            children: [
              Center(
                // Center the driver's profile picture
                child: ClipOval(
                  // Clip the image into a circular shape
                  child: SizedBox(
                    // Container to define image size
                    width: 120, // Set width of the circle
                    height: 120, // Set height of the circle
                    child: ImageFrame(
                      // Display driver's profile picture using ImageFrame widget
                      firebaseUid: widget
                              .request.futureTrip?.driver?.firebaseUid ??
                          '', // Use driver's Firebase UID or empty string if null
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height:
                      16), // Add space between profile picture and next section

              // Driver's name
              ListTile(
                title: Text(widget.request.futureTrip?.driver?.name ?? 'N/A',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            14)), // Display driver's name or 'N/A' if null
                subtitle: Text("🚗 Driver"),
              ),

              // Driver's rating
              ListTile(
                title: Text(
                    "⭐ Driver Rating: \n${widget.request.futureTrip?.driver?.driverRating ?? 'N/A'}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)), // Display driver's rating or 'N/A'
              ),

              // Start location of the trip
              ListTile(
                title: Text(
                    "📍 Start Location: \n${widget.request.futureTrip?.startLocation ?? 'N/A'}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)), // Display start location or 'N/A'
              ),

              // Destination of the trip
              ListTile(
                title: Text(
                    "📌 Destination: \n${widget.request.futureTrip?.destination ?? 'N/A'}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)), // Display destination or 'N/A'
              ),

              // Pickup location for the rider
              ListTile(
                title: Text(
                    "🛣️ Pickup Location: \n${widget.request.riderLocation ?? 'N/A'}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            14)), // Display rider's pickup location or 'N/A'
              ),

              // Estimated pickup time, converting Unix timestamp to readable format
              ListTile(
                title: Text(
                    "⏰ Estimated Pickup Time: \n${widget.request.pickupTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.pickupTime! * 1000).toString() : 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // Estimated dropoff time, converting Unix timestamp to readable format
              ListTile(
                title: Text(
                    "🕗 Estimated Dropoff Time: \n${widget.request.dropoffTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.dropoffTime! * 1000).toString() : 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // Car information including color, make, and model
              ListTile(
                title: Text(
                    "🚙 Car: \n${widget.request.futureTrip?.driver?.name ?? 'N/A'} will be driving a ${widget.request.futureTrip?.driver?.carColor ?? 'N/A'} ${widget.request.futureTrip?.driver?.carMake ?? 'N/A'} ${widget.request.futureTrip?.driver?.carModel ?? 'N/A'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // Rider's cost for the trip
              ListTile(
                title: Text(
                    "💲 Cost: \n\\${widget.request.riderCost.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)), // Format cost to 2 decimal places
              ),

              // Distance of the trip in miles
              ListTile(
                title: Text(
                    "🗺️ Distance: \n${widget.request.distance.toStringAsFixed(2)} mi",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)), // Format distance to 2 decimal places
              ),
            ],
          ),
        ),
      ),
    );
  }
}
