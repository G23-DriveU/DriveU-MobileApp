import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

// Used to display trips for Drivers using the application
// TODO: Display all of the info for the trip in a nice way
class FutureTripPage extends StatefulWidget {
  final FutureTrip? trip;
  final RideRequest? rideRequest;
  final LocationData? userPosition;
  const FutureTripPage(
      {super.key, this.trip, required this.userPosition, this.rideRequest});

  @override
  State<FutureTripPage> createState() => _FutureTripPageState();
}

class _FutureTripPageState extends State<FutureTripPage> {
  // Get a list of the ride requests for a trip
  Future<List<RideRequest>> _getRideRequests() async {
    return await TripApi()
        .getRideRequests({"futureTripId": widget.trip!.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return widget.trip != null ? driverFutureTrip() : riderFutureTrip();
  }

  // Future trip page for driver's
  Scaffold driverFutureTrip() {
    return Scaffold(
      persistentFooterButtons: [
        Center(child: ElevatedButton(onPressed: () {}, child: Text("Start")))
      ],
      body: Column(
        children: [
          Text("Start Location: ${widget.trip?.startLocation}"),
          Text("Destination: ${widget.trip?.destination}"),
          // Add more details as needed
          if (SingleUser().getUser()!.id == widget.trip?.driverId)
            FutureBuilder<List<RideRequest>>(
                future: _getRideRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                        height: 90, child: CircularProgressIndicator());
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
                                  onPressed: () {},
                                  child: ImageFrame(
                                      firebaseUid: snapshot
                                          .data![index].rider!.firebaseUid!)),
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

  // Future trip for riders
  Scaffold riderFutureTrip() {
    return Scaffold(
      persistentFooterButtons: [
        Center(
            child: ElevatedButton(onPressed: () {}, child: Text("Picked Up")))
      ],
      body: Column(
        children: [
          Text(
              "Start Location: ${widget.rideRequest?.futureTrip!.startLocation}"),
          Text("Destination: ${widget.rideRequest?.futureTrip!.destination}"),
          // Add more details as needed
          Text("Status: ${widget.rideRequest!.status}"),
          Text("Your Estimated Contribution: ${widget.rideRequest!.riderCost}")
        ],
      ),
    );
  }
}
