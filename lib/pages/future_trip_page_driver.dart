import 'package:driveu_mobile_app/helpers/helpers.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  final Set<Polyline> _polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints();

  // Get a list of the ride requests for a trip
  Future<List<RideRequest>> _getRideRequests() async {
    return await TripApi()
        .getRideRequests({"futureTripId": widget.trip.id.toString()});
  }

  Future<void> getRoute(FutureTrip trip, RideRequest riderRequest) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: dotenv
          .env['GOOGLE_MAPS_API_KEY'], // Replace with your Google Maps API Key
      request: PolylineRequest(
        origin: PointLatLng(trip.startLocationLat, trip.startLocationLng),
        destination: PointLatLng(trip.destinationLat, trip.destinationLng),
        wayPoints: [
          PolylineWayPoint(
            location:
                '${riderRequest.riderLocationLat},${riderRequest.riderLocationLng}',
          ),
        ],
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      ));
    });
  }

  // Show rider info for drivers when looking through ride request
  void _showRiderInfo(
      BuildContext context, RideRequest riderRequest, FutureTrip trip) async {
    await getRoute(trip, riderRequest);
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

                        // Attach the accepted ride request
                        setState(() {
                          widget.trip.request = riderRequest;
                        });

                        Navigator.of(context).pop();
                      },
                      child: Text("Accept")),
                  ElevatedButton(
                      onPressed: () async {
                        await TripApi().rejectRideRequest(
                            {"rideRequestId": riderRequest.id.toString()});
                        setState(() {
                          // Remove the request from list of ride requests
                        });

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
                      zoom: 8,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('driverLocation'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
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
                      Marker(
                        markerId: MarkerId('riderLocation'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange),
                        position:
                            LatLng(trip.destinationLat, trip.destinationLng),
                        infoWindow: InfoWindow(title: 'Final Destination'),
                      )
                    },
                    // Generate polyline for the route
                    polylines: _polylines,
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
  void initState() {
    super.initState();
    // getRoute(widget.trip, widget.trip.request!);
  }

  @override
  Widget build(BuildContext context) {
    // if (_polylines.isEmpty) getRoute(widget.trip, widget.trip.request!);
    return Scaffold(
      persistentFooterButtons: [
        Center(
            // TODO: Perhaps some 'advanceTripStage' for onPressed
            child: ElevatedButton(onPressed: _startTrip, child: Text("Start")))
      ],
      body: Column(
        children: [
          Text("Start Location: ${widget.trip.startLocation}"),
          Text("Destination: ${widget.trip.destination}"),
          // Give the driver the ability to view a list of ride request
          if (widget.trip.request == null)
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
                }),
          // Currently has a rider for the trip
          // TODO: Once a ride request was accepted, we attach it to the trip
          if (widget.trip.request != null)
            // TODO: might need to call getRoute
            Column(
              children: [
                Text("Here is the rider's information"),
                Text(widget.trip.request!.rider!.name),
                Text(
                    "${widget.trip.request!.rider!.name} has a rating of ${widget.trip.request!.rider!.riderRating}"),
                Text(
                    "Rider Pick up Location: ${widget.trip.request!.riderLocation}"),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.trip.startLocationLat,
                          widget.trip.startLocationLng),
                      zoom: 8,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('driverLocation'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                        position: LatLng(widget.trip.startLocationLat,
                            widget.trip.startLocationLng),
                        infoWindow: InfoWindow(title: 'Driver Location'),
                      ),
                      Marker(
                        markerId: MarkerId('riderLocation'),
                        position: LatLng(widget.trip.request!.riderLocationLat,
                            widget.trip.request!.riderLocationLng),
                        infoWindow: InfoWindow(title: 'Rider Location'),
                      ),
                      Marker(
                        markerId: MarkerId('riderLocation'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange),
                        position: LatLng(widget.trip.destinationLat,
                            widget.trip.destinationLng),
                        infoWindow: InfoWindow(title: 'Final Destination'),
                      )
                    },
                    // Generate polyline for the route
                    polylines: _polylines,
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
