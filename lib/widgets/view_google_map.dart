import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewGoogleMap extends StatefulWidget {
  const ViewGoogleMap({super.key});

  @override
  State<ViewGoogleMap> createState() => _ViewGoogleMapState();
}

class _ViewGoogleMapState extends State<ViewGoogleMap> {
  // Manipulate the camera
  late GoogleMapController mapController;
  late final LatLng _center = const LatLng(28.6016, -81.2005);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        initialCameraPosition: CameraPosition(target: _center, zoom: 11),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
