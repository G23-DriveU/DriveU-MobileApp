import 'package:driveu_mobile_app/helpers/helpers.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FutureTripPageDriver extends StatefulWidget {
  final FutureTrip trip;
  const FutureTripPageDriver({super.key, required this.trip});

  @override
  State<FutureTripPageDriver> createState() => _FutureTripPageDriverState();
}

class _FutureTripPageDriverState extends State<FutureTripPageDriver> {
  late Location location;
  // Get a list of the ride requests for a trip
  Future<List<RideRequest>> _getRideRequests() async {
    return await TripApi()
        .getRideRequests({"futureTripId": widget.trip.id.toString()});
  }

  // Show rider info for drivers when looking through ride request
  void _showRiderInfo(
      BuildContext context, RideRequest riderRequest, FutureTrip trip) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        await TripApi().acceptRideRequest(
                            {"rideRequestId": riderRequest.id.toString()});

                        // Add the ride request to trip object
                        trip.request = riderRequest;
                        Navigator.of(context).pop();
                        // TODO: Add the rider to the future trip so that way we
                        // can replace the ride requests with the rider's information
                      },
                      child: Text("Accept")),
                  ElevatedButton(
                      onPressed: () async {
                        await TripApi().rejectRideRequest(
                            {"rideRequestId": riderRequest.id.toString()});
                        Navigator.of(context).pop();
                      },
                      child: Text("Reject")),
                ],
              )
            ],
            content: Column(
              children: [
                Text("Here is the rider's information"),
                Text(riderRequest.rider!.name),
                Text(
                    "${riderRequest.rider!.name} has a rating of ${riderRequest.rider!.riderRating}"),
                Text("Rider Pick up Location: ${riderRequest.riderLocation}"),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          LatLng(trip.startLocationLat, trip.startLocationLng),
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('driverLocation'),
                        position: LatLng(
                            trip.startLocationLat, trip.startLocationLng),
                        infoWindow: InfoWindow(title: 'Driver Location'),
                      ),
                      Marker(
                        markerId: MarkerId('riderLocation'),
                        position: LatLng(riderRequest.riderLocationLat,
                            riderRequest.riderLocationLng),
                        infoWindow: InfoWindow(title: 'Rider Location'),
                      ),
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _startTrip() async {
    print("Starting the trip");
    await TripApi().startTrip({
      'futureTripId': widget.trip.id.toString(),
      'startTime': getSecondsSinceEpoch().toString()
    });

    // Start tracking the driver's location
    _trackLocation();
  }

  // Used to track the driver's (and rider's) location during the trip
  void _trackLocation() {
    location = Location();

    location.onLocationChanged.listen((LocationData ld) {
      // Check for rider pick up

      // Check for first arrival at destination

      // If round trip, start second leg

      // Check for drop off
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Center(
            child: ElevatedButton(onPressed: _startTrip, child: Text("Start")))
      ],
      body: Column(
        children: [
          Text("Start Location: ${widget.trip.startLocation}"),
          Text("Destination: ${widget.trip.destination}"),
          // Add more details as needed
          if (SingleUser().getUser()!.id == widget.trip.driverId)
            FutureBuilder<List<RideRequest>>(
                future: _getRideRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                        height: 45, child: CircularProgressIndicator());
                  } else if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text("No Requests"),
                    );
                  } else if (snapshot.hasData) {
                    return SizedBox(
                      height: 90,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.all(8),
                              child: ElevatedButton(
                                // View the rider's information
                                onPressed: () => _showRiderInfo(context,
                                    snapshot.data![index], widget.trip),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(16),
                                ),
                                child: ImageFrame(
                                  firebaseUid:
                                      snapshot.data![index].rider!.firebaseUid!,
                                ),
                              ),
                            );
                          }),
                    );
                  } else {
                    return Center(
                      child: Text("Error Loading Ride Request"),
                    );
                  }
                })
        ],
      ),
    );
  }
}
