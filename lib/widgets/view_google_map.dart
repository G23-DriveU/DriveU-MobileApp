import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ViewGoogleMap extends StatefulWidget {
  const ViewGoogleMap({super.key});

  @override
  State<ViewGoogleMap> createState() => _ViewGoogleMapState();
}

class _ViewGoogleMapState extends State<ViewGoogleMap> {
  // Manipulate the camera
  late GoogleMapController mapController;
  late LatLng _center = const LatLng(28.6016, -81.2005);
  LocationData? _userPosition;
  Set<Marker>? _trips;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // TODO: Need to add the radius and the user's location
  void _loadMarkers() async {
    // Load the markers
    final markers = await TripApi().getTrips({
      'riderId': SingleUser().getUser()!.id.toString(),
      'radius': '100',
      'lat': '28.6016',
      'lng': '-81.2005',
      'roundTrip': 'false'
    });

    setState(() {
      _trips = markers;
    });
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
    setState(() {
      // Set the user's position
      _userPosition = userPostion;
      _center = LatLng(userPostion.latitude!, userPostion.longitude!);
      _trips?.add(Marker(
        markerId: const MarkerId('user'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: _center,
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'You are here',
        ),
      ));
    });
    // Add the current users' location to the marker set
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: _trips ?? {},
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        initialCameraPosition: CameraPosition(target: _center, zoom: 11),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
