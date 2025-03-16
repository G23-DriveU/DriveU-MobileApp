import 'package:driveu_mobile_app/model/ride_request.dart'; // Import the RideRequest model to use ride request data
import 'package:driveu_mobile_app/widgets/image_frame.dart'; // Import ImageFrame widget to display driver's profile picture
import 'package:flutter/material.dart'; // Import Flutter's material design package for UI components

// Stateful widget to display future trip details for the rider
class FutureTripPageRider extends StatefulWidget {
  final RideRequest request; // RideRequest object containing trip details

  // Constructor requiring a RideRequest object
  const FutureTripPageRider({super.key, required this.request});

  @override
  State<FutureTripPageRider> createState() => _FutureTripPageRiderState(); // Create state for the widget
}

// State class for FutureTripPageRider
class _FutureTripPageRiderState extends State<FutureTripPageRider> {
  @override
  Widget build(BuildContext context) { // Build method to define the widget tree
    return Scaffold( // Scaffold provides a page layout structure
      persistentFooterButtons: [ // Footer buttons at the bottom of the page
        Row( // Row layout to arrange buttons horizontally
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly across the row
          children: [
            ElevatedButton( // 'Picked Up' button
              onPressed: () {}, // Currently empty onPressed callback for button functionality
              child: Text("Picked Up 🚗", style: TextStyle(fontWeight: FontWeight.bold)), // Button label with bold text
            ),
          
            /*ElevatedButton( // 'Cancel' button
              onPressed: () {}, // Currently empty onPressed callback
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Red background for cancel button
              child: Text("Cancel ❌", style: TextStyle(fontWeight: FontWeight.bold)), // Button label with bold text
            )
            */
          ],
        )
      ],
      body: Padding( // Add padding around the content
        padding: const EdgeInsets.all(16.0), // 16px padding on all sides
        child: ListView( // ListView allows content to be scrollable
          children: [
            Center( // Center the driver's profile picture
              child: ClipOval( // Clip the image into a circular shape
                child: Container( // Container to define image size
                  width: 120, // Set width of the circle
                  height: 120, // Set height of the circle
                  child: ImageFrame( // Display driver's profile picture using ImageFrame widget
                    firebaseUid: widget.request.futureTrip?.driver?.firebaseUid ?? '', // Use driver's Firebase UID or empty string if null
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // Add space between profile picture and next section

            // Driver's name
            ListTile( 
              title: Text("🚗 Driver: \n${widget.request.futureTrip?.driver?.name ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Display driver's name or 'N/A' if null
            ),

            // Driver's rating
            ListTile(
              title: Text("⭐ Driver Rating: \n${widget.request.futureTrip?.driver?.driverRating ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Display driver's rating or 'N/A'
            ),

            // Start location of the trip
            ListTile(
              title: Text("📍 Start Location: \n${widget.request.futureTrip?.startLocation ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Display start location or 'N/A'
            ),

            // Destination of the trip
            ListTile(
              title: Text("📌 Destination: \n${widget.request.futureTrip?.destination ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Display destination or 'N/A'
            ),

            // Pickup location for the rider
            ListTile(
              title: Text("🛣️ Pickup Location: \n${widget.request.riderLocation ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Display rider's pickup location or 'N/A'
            ),

            // Estimated pickup time, converting Unix timestamp to readable format
            ListTile(
              title: Text("⏰ Estimated Pickup Time: \n${widget.request.pickupTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.pickupTime! * 1000).toString() : 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // Estimated dropoff time, converting Unix timestamp to readable format
            ListTile(
              title: Text("🕗 Estimated Dropoff Time: \n${widget.request.dropoffTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.request.dropoffTime! * 1000).toString() : 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // Car information including color, make, and model
            ListTile(
              title: Text("🚙 Car: \n${widget.request.futureTrip?.driver?.name ?? 'N/A'} will be driving a ${widget.request.futureTrip?.driver?.carColor ?? 'N/A'} ${widget.request.futureTrip?.driver?.carMake ?? 'N/A'} ${widget.request.futureTrip?.driver?.carModel ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // Rider's cost for the trip
            ListTile(
              title: Text("💲 Cost: \n\\${widget.request.riderCost.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Format cost to 2 decimal places
            ),

            // Distance of the trip in miles
            ListTile(
              title: Text("🗺️ Distance: \n${widget.request.distance.toStringAsFixed(2)} mi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Format distance to 2 decimal places
            ),
          ],
        ),
      ),
    );
  }
}
