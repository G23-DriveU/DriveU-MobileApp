import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class ViewGoogleMap extends StatefulWidget {
  const ViewGoogleMap({super.key});

  @override
  State<ViewGoogleMap> createState() => _ViewGoogleMapState();
}

class _ViewGoogleMapState extends State<ViewGoogleMap> {
  // Manipulate the camera
  late GoogleMapController mapController;
  LatLng? _center;
  LocationData? _userPosition;
  Set<Marker>? _trips;
  Set<Circle>? searchRadiusOverlay = {};
  // Used to cancel async execution after navigation off of this screen
  bool _isMounted = true;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // TODO: Will need to add another for the driver which will enable them to set their ending location?
  void _handleLongPressRider(LatLng position) {
    final mapState = Provider.of<MapState>(context, listen: false);
    if (_isMounted) {
      setState(() {
        if (mapState.startLocation == null) {
          Provider.of<MapState>(context, listen: false)
              .setStartLocation(position);
        } else if (mapState.endLocation == null) {
          Provider.of<MapState>(context, listen: false)
              .setEndLocation(position);
        } else {
          // Reset the markers if both are already set
          Provider.of<MapState>(context, listen: false)
              .setStartLocation(position);
          Provider.of<MapState>(context, listen: false).setEndLocation(null);
        }
      });
    }
  }

  // TODO: Need to add the radius and the user's location
  void _loadMarkers() async {
    final mapState = Provider.of<MapState>(context, listen: false);
    // Load the markers
    final markers = await TripApi().getTrips({
      'riderId': SingleUser().getUser()!.id.toString(),
      'radius': mapState.radius.toString(),
      'lat': '28.6016',
      'lng': '-81.2005',
      'roundTrip': mapState.wantRoundTrip.toString(),
      'riderLocation': 'Knight Library, Orlando, FL'
    }, context, _showTripInfo);

    if (_isMounted) {
      setState(() {
        _trips = markers;
      });
    }
  }

  // Get the current user's location
  void _getUserLocation() async {
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

    // Grab the permission
    final userPostion = await userLocation.getLocation();
    if (_isMounted) {
      setState(() {
        // Set the user's position
        _userPosition = userPostion;
        _center = LatLng(userPostion.latitude!, userPostion.longitude!);
        _trips?.add(Marker(
          markerId: const MarkerId('user'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          position: _center!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ));
      });
    }
    // Add the current users' location to the marker set
  }

  void _showTripInfo(BuildContext context, FutureTrip trip) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${trip.driver!.name}'s Trip"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Destination: ${trip.destination}"),
                Text("Start Location: ${trip.startLocation}"),
                Text("Driver: ${trip.driver!.name}"),
                Text("Car: ${trip.driver!.carMake} ${trip.driver!.carModel}"),
                // Add more details as needed
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement join ride request logic here
                  Navigator.of(context).pop();
                },
                child: const Text('Join Ride'),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    // Get the current users' location
    _getUserLocation();
    // Load the initial set of markers
    _loadMarkers();
  }

  @override
  void dispose() {
    super.dispose();
    _isMounted = false;
  }

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);

    if (mapState.startLocation != null) {
      _trips?.add(Marker(
        markerId: const MarkerId('start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: mapState.startLocation!,
        infoWindow: const InfoWindow(title: 'Start Location'),
      ));
    }
    if (mapState.endLocation != null) {
      _trips?.add(Marker(
        markerId: const MarkerId('end'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: mapState.endLocation!,
        infoWindow: const InfoWindow(title: 'End Location'),
      ));
    }

    // Convert radius from miles to meters
    double radiusInMeters = mapState.radius * 1609.34;

    if (mapState.startLocation != null) {
      searchRadiusOverlay!.add(Circle(
        circleId: const CircleId('startCircle'),
        center: mapState.startLocation!,
        radius: radiusInMeters,
        fillColor: Colors.blue.withOpacity(0.5),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));
    }
    return _center == null
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: GoogleMap(
                markers: _trips ?? {},
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                initialCameraPosition:
                    CameraPosition(target: _center!, zoom: 11),
                onMapCreated: _onMapCreated,
                // TODO: This is going to have to be different depending on if rider or driver
                onLongPress: _handleLongPressRider,
                circles: searchRadiusOverlay ?? {}),
          );
  }
}
