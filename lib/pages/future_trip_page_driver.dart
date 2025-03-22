import 'package:driveu_mobile_app/helpers/helpers.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/pages/rides_page.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/google_maps_utils.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

// TODO: need to, in real time, track GPS coor when trip is active so you don't need to pull
// down and refresh the page to get most up to date GPS coordinates.
class FutureTripPageDriver extends StatefulWidget {
  FutureTrip trip;
  TripStage stage;
  FutureTripPageDriver({super.key, required this.trip, required this.stage});
  @override
  State<FutureTripPageDriver> createState() => _FutureTripPageDriverState();
}

class _FutureTripPageDriverState extends State<FutureTripPageDriver> {
  late Location location;
  final Set<Polyline> _polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints();
  GoogleMapController? _mapController;
  bool _isMounted = true;
  // Keep track of the users location
  LocationData? _userPosition;

  Future<void> _getUserLocation() async {
    Location userLocation = Location();

    bool serviceEnabled = await userLocation.serviceEnabled();
    // Check to make sure location service is enabled
    if (!serviceEnabled) {
      serviceEnabled = await userLocation.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionsGranted = await userLocation.hasPermission();
    // Ensure permissions are granted
    if (permissionsGranted == PermissionStatus.denied) {
      permissionsGranted = await userLocation.requestPermission();
      if (permissionsGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Grab the location
    _userPosition = await userLocation.getLocation();
  }

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

    if (_isMounted) {
      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        ));
      });
    }
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
                          widget.trip.isFull = true;
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
                        markerId: MarkerId('destinationLocation'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange),
                        position:
                            LatLng(trip.destinationLat, trip.destinationLng),
                        infoWindow: InfoWindow(title: 'Final Destination'),
                      )
                    },
                    // Generate polyline for the route
                    polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      LatLngBounds bounds = GoogleMapsUtils().calculateBounds([
                        LatLng(trip.startLocationLat, trip.startLocationLng),
                        LatLng(trip.destinationLat, trip.destinationLng),
                        LatLng(riderRequest.riderLocationLat,
                            riderRequest.riderLocationLng)
                      ]);
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 50),
                      );
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
    // Start the first leg of the trip
    if (widget.stage == TripStage.notStarted) {
      await TripApi().startTrip({
        'futureTripId': widget.trip.id.toString(),
        'startTime': getSecondsSinceEpoch().toString()
      });
      setState(() {
        widget.stage = TripStage.startedFirstLeg;
      });
      return;
    }
    // Start the second leg of a round trip
    if (widget.stage == TripStage.endFirstLeg) {
      await TripApi().startSecondLeg({
        "rideRequestId": widget.trip.request!.id.toString(),
        "leavingTime": getSecondsSinceEpoch().toString()
      });
      setState(() {
        widget.stage = TripStage.startSecondLeg;
      });
    }
    // Start tracking the driver's location
    // _trackLocation();
  }

  void _endTrip() async {
    print("Ending first leg of trip");
    // End the first leg of the trip
    if (widget.stage == TripStage.pickedUp) {
      // Ensure the driver is within the valid stopping range of the
      int res = await TripApi().reachDestination({
        "rideRequestId": widget.trip.request!.id.toString(),
        "arrivalTime": getSecondsSinceEpoch().toString(),
        "lat": _userPosition!.latitude.toString(),
        "lng": _userPosition!.longitude.toString()
      });

      if (res == 200) {
        setState(() {
          widget.stage = TripStage.endFirstLeg;
        });
      }
      // Display toast message to show that the driver isn't registering close enough to the location
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Sorry, you are not close enough to the destination. Try again later."),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    // TODO: Add stage for dropping off rider
  }

  Future<void> _droppedOff() async {
    await TripApi().dropOffRider({
      "futureTripId": widget.trip.id.toString(),
      "dropOffTime": getSecondsSinceEpoch().toString(),
      "lat": _userPosition!.latitude.toString(),
      "lng": _userPosition!.longitude.toString()
    });
    // No need to update trip state since it is done
  }

  // Used to track the driver's (and rider's) location during the trip
  void _trackLocation() {
    location = Location();

    location.onLocationChanged.listen((LocationData ld) async {
      if (!_isMounted) return;

      LatLng currentLocation = LatLng(ld.latitude!, ld.longitude!);

      // Check if the driver is within a certain distance of the final destination
      double distanceToDestinationInMeters = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        widget.trip.destinationLat,
        widget.trip.destinationLng,
      );

      if (distanceToDestinationInMeters / 1609.344 <= 0.5) {
        // 50 meters threshold
        print("Driver has reached the final destination.");
        await TripApi().reachDestination({
          'rideRequestId': widget.trip.request!.id.toString(),
          'arrivalTime': getSecondsSinceEpoch().toString(),
          'lat': ld.latitude.toString(),
          'lng': ld.longitude.toString()
        });

        // Stop tracking location
        location.onLocationChanged.drain();
        return;
      }

      // Additional checks for other phases of the trip can be added here
      // For example, checking for rider pick-up or intermediate stops
    });
  }

  // Used in tandem with the 'RefreshIndicator' to get updated
  // trip details when looking at a specific trip.
  Future<void> _refreshTrip() async {
    // Fetch the updated trip information
    FutureTrip? updatedTrip = await TripApi()
        .getFutureTrip({'futureTripId': widget.trip.id.toString()});

    if (updatedTrip != null) {
      setState(() {
        widget.trip = updatedTrip;
        widget.stage = getTripStage(widget.trip, null);
      });
    }
  }

  // Display the different actions for each trip stage for the driver.
  // The same looking button, but with different actions will appear for each stage
  ElevatedButton tripStage(TripStage stage) {
    switch (stage) {
      case TripStage.notStarted:
        return ElevatedButton(
            onPressed: widget.trip.isFull ? _startTrip : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Theme.of(context).disabledColor,
            ),
            child: Text(
              "Start",
              style: TextStyle(
                color: widget.trip.isFull
                    ? Colors.white
                    : Colors.grey[700], // Adjust text color
              ),
            ));
      case TripStage.pickedUp:
        return ElevatedButton(onPressed: _endTrip, child: const Text("End"));
      case TripStage.startSecondLeg:
        return ElevatedButton(
            onPressed: _startTrip, child: const Text("Start"));
      default:
        return ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Theme.of(context).disabledColor,
            ),
            child: Text(
              "End",
              style: TextStyle(
                color: Colors.grey[700], // Adjust text color
              ),
            ));
    }
  }

  @override
  void initState() {
    super.initState();
    // Get the users location so we can use GPS coordinates to verify locations
    _getUserLocation();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Trip status is ${widget.stage}\n");
    // If the a request has been accepted, then call getRoute to display the route
    if (widget.trip.isFull) getRoute(widget.trip, widget.trip.request!);
    return Scaffold(
      // Display a different action button depending on the stage of the trip
      persistentFooterButtons: [Center(child: tripStage(widget.stage))],
      body: RefreshIndicator(
        onRefresh: _refreshTrip,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
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
                                      firebaseUid: snapshot
                                          .data![index].rider!.firebaseUid!,
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
              if (widget.trip.request != null)
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
                            position: LatLng(
                                widget.trip.request!.riderLocationLat,
                                widget.trip.request!.riderLocationLng),
                            infoWindow: InfoWindow(title: 'Rider Location'),
                          ),
                          Marker(
                            markerId: MarkerId('destinationLocation'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueOrange),
                            position: LatLng(widget.trip.destinationLat,
                                widget.trip.destinationLng),
                            infoWindow: InfoWindow(title: 'Final Destination'),
                          )
                        },
                        // Generate polyline for the route
                        polylines: _polylines,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                          LatLngBounds bounds =
                              GoogleMapsUtils().calculateBounds([
                            LatLng(widget.trip.startLocationLat,
                                widget.trip.startLocationLng),
                            LatLng(widget.trip.destinationLat,
                                widget.trip.destinationLng),
                            LatLng(widget.trip.request!.riderLocationLat,
                                widget.trip.request!.riderLocationLng)
                          ]);
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngBounds(bounds, 50),
                          );
                        },
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
