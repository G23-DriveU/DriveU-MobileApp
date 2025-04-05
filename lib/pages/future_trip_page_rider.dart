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
  // Keep track of the users location
  late RideRequest request;
  late TripStage stage;

  // Reports to the API that the rider has been picked up by the driver
  Future<void> _pickedUp() async {
    await TripApi().pickUpRider({
      "rideRequestId": request.id.toString(),
      "pickupTime": getSecondsSinceEpoch().toString()
    });
    setState(() {
      stage = TripStage.pickedUp;
    });
  }

  // Used in tandem with the 'RefreshIndicator' to get updated
  // trip details when looking at a specific trip.
  Future<void> _refreshTrip() async {
    // Fetch the updated trip information
    FutureTrip? updatedTrip = await TripApi()
        .getFutureTrip({'futureTripId': request.futureTripId.toString()});

    if (updatedTrip != null && updatedTrip.request != null) {
      setState(() {
        // Only update if the request has been accepted
        // request = updatedTrip.request ?? request;
        request.pickupTime = updatedTrip.request!.pickupTime;
        stage = getTripStage(updatedTrip, null);
        // Pop out of a one-way trip
        if (!request.roundTrip && stage == TripStage.endFirstLeg) {
          Navigator.of(context).pop("refresh");
        }
        if (stage == TripStage.tripEnd) {
          Navigator.of(context).pop("refresh");
        }
      });
    }
  }

  ElevatedButton tripStage(TripStage stage) {
    switch (stage) {
      case TripStage.notStarted:
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).disabledColor,
          ),
          child: Text("Picked Up",
              style: TextStyle(
                  color: Colors.grey[700], // Adjust text color
                  fontWeight: FontWeight.bold)), // Button label with bold text
        );
      case TripStage.startedFirstLeg:
        return ElevatedButton(
          // 'Picked Up' button
          onPressed: _pickedUp,
          child: Text("Picked Up",
              style: TextStyle(
                color: Colors.white, // Adjust text color
              )), // Button label with bold text
        );
      case TripStage.startSecondLeg:
        return ElevatedButton(
          // 'Picked Up' button
          onPressed: null,
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
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).disabledColor,
          ),
          child: Text("Picked Up",
              style: TextStyle(
                  color: Colors.grey[700], // Adjust text color
                  fontWeight: FontWeight.bold)), // Button label with bold text
        );
    }
  }

  @override
  void initState() {
    super.initState();
    request = widget.request;
    stage = widget.stage;
  }

  @override
  Widget build(BuildContext context) {
    print("Trip status is $stage\n");
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
            tripStage(stage),
          ],
        )
      ],

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshTrip,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ImageFrame(
                        firebaseUid:
                            request.futureTrip?.driver?.firebaseUid ?? '',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height:
                        16), // Add space between profile picture and next section

                // Driver's name
                ListTile(
                  title: Text("🚗 Driver",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              18)), // Display driver's name or 'N/A' if null
                  subtitle: Text(request.futureTrip?.driver?.name ?? 'N/A'),
                ),
                // Driver's rating
                ListTile(
                  title: Text("⭐ Driver Rating",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                      (request.futureTrip?.driver?.driverRating ?? 'N/A')
                          .toString()),
                ),
                // Start location of the trip
                ListTile(
                  title: Text("📍 Start Location",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text((request.futureTrip?.startLocation ??
                      'N/A')), // Display start location or 'N/A'
                ),

                // Destination of the trip
                ListTile(
                  title: Text("📌 Destination ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text((request.riderLocation ??
                      'N/A')), // Display destination or 'N/A' \n${request.riderLocation ?? 'N/A'}
                ),
                // Pickup location for the rider
                ListTile(
                  title: Text("🛣️ Pickup Location: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                  subtitle: Text((request.riderLocation ??
                      'N/A')), // Display rider's pickup location or 'N/A'
                ),

                // Estimated pickup time, converting Unix timestamp to readable format
                ListTile(
                  title: Text("⏰ Estimated Pickup Time",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text((request.pickupTime != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                              widget.request.pickupTime! * 1000)
                          .toString()
                      : 'N/A')),
                ),

                // Estimated dropoff time, converting Unix timestamp to readable format
                ListTile(
                  title: Text("🕗 Estimated Dropoff Time: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text((request.dropoffTime != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                              widget.request.dropoffTime! * 1000)
                          .toString()
                      : 'N/A')),
                ),

                // Car information including color, make, and model
                ListTile(
                  title: Text("🚙 Car: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                      "${request.futureTrip?.driver?.name ?? 'N/A'} will be driving a ${request.futureTrip?.driver?.carColor ?? 'N/A'} ${widget.request.futureTrip?.driver?.carMake ?? 'N/A'} ${widget.request.futureTrip?.driver?.carModel ?? 'N/A'}"),
                ),

                // Rider's cost for the trip
                ListTile(
                    title: Text("💲 Cost: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(request.riderCost
                        .toStringAsFixed(2)) // Format cost to 2 decimal places
                    ),

                // Distance of the trip in miles
                ListTile(
                  title: Text("🗺️ Distance: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("${request.distance.toStringAsFixed(2)} mi"),
                  // Format distance to 2 decimal places
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
