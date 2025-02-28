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
            child: ElevatedButton(onPressed: () {}, child: Text("Picked Up")))
      ],
      body: Column(
        children: [
          Row(
            children: [
              Text("Driver: ${widget.request.futureTrip?.driver?.name}"),
              ImageFrame(
                  firebaseUid: widget.request.futureTrip!.driver!.firebaseUid!)
            ],
          ),
          Text(
              "Driver Rating: ${widget.request.futureTrip?.driver?.driverRating}"),
          Text("Start Location: ${widget.request.futureTrip?.startLocation}"),
          Text("Destination: ${widget.request.futureTrip?.destination}"),
          Text("Pickup Location: ${widget.request.riderLocation}"),
          Text(
              "Estimated Pickup Time: ${widget.request.pickupTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.pickupTime! * 1000) : 'N/A'}"),
          Text(
              "Estimated Dropoff Time: ${widget.request.dropoffTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.dropoffTime! * 1000) : 'N/A'}"),
          // Display car information
          Row(
            children: [
              Text(
                  "${widget.request.futureTrip?.driver?.name} will be driving a ${widget.request.futureTrip!.driver!.carColor!} ${widget.request.futureTrip!.driver!.carMake!} ${widget.request.futureTrip!.driver!.carModel!}")
            ],
          ),
          Text("Cost: \$${widget.request.riderCost.toStringAsFixed(2)}"),
          Text("Distance: ${widget.request.distance.toStringAsFixed(2)} mi"),
          // Add more details as needed
        ],
      ),
    );
  }
}
