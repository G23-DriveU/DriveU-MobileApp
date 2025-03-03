import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/driver_alert_dialog_future_trip.dart';
import 'package:driveu_mobile_app/widgets/rider_alert_dialog_future_trip.dart';
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
    if (_isMounted) {
      final mapState = Provider.of<MapState>(context, listen: false);
      setState(() {
        if (mapState.startLocation == null) {
          Provider.of<MapState>(context, listen: false)
              .setStartLocation(position);
        } else if (mapState.endLocation == null) {
          Provider.of<MapState>(context, listen: false)
              .setEndLocation(position);
          // Get a new set of trips to display
          _loadMarkers();
        } else {
          // Reset the markers if both are already set
          Provider.of<MapState>(context, listen: false)
              .setStartLocation(position);
          Provider.of<MapState>(context, listen: false).setEndLocation(null);
        }
      });
    }
  }

  // Retrieves a set of markers of future trips. For riders, they see a set of
  // future trips to join. For drivers, they see a set of future trips they have planned.
  void _loadMarkers() async {
    final mapState = Provider.of<MapState>(context, listen: false);
    // Load the markers
    final markers = SingleUser().getUser()!.driver
        // Retrieve driver's trips
        ? await TripApi().getTrips({
            'driverId': SingleUser().getUser()!.id.toString(),
          }, context, _showTripInfo)
        // Retrieve trips by radius for rider
        : await TripApi().getTrips({
            'riderId': SingleUser().getUser()!.id.toString(),
            'radius': mapState.radius.toString(),
            'lat': mapState.endLocation?.latitude.toString() ??
                _center!.latitude.toString(),
            'lng': mapState.endLocation?.longitude.toString() ??
                _center!.longitude.toString(),
            'roundTrip': mapState.wantRoundTrip.toString(),
            'riderLat': _userPosition!.latitude.toString(),
            'riderLng': _userPosition!.longitude.toString()
          }, context, _showTripInfo);

    if (_isMounted) {
      setState(() {
        _trips = markers;
      });
    }
  }

  // Get the current user's location
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

    // Grab the permission
    final userPostion = await userLocation.getLocation();
    if (_isMounted) {
      final mapState = Provider.of<MapState>(context, listen: false);
      setState(() {
        // Set the user's position
        _userPosition = userPostion;
        _center = LatLng(userPostion.latitude!, userPostion.longitude!);
        mapState.setEndLocation(_center);
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
          return SingleUser().getUser()!.driver
              ? DriverAlertDialogFutureTrip(
                  trip: trip, userPosition: _userPosition)
              : RiderAlertDialogFutureTrip(
                  trip: trip, userPosition: _userPosition);
        });
  }

  @override
  void initState() {
    super.initState();
    // Get the current users' location and then load the markers
    _getUserLocation().then((_) {
      if (_center != null) {
        _loadMarkers();
      }
    });

    // // Add a listener to the MapState to reload markers when the radius changes
    final mapState = Provider.of<MapState>(context, listen: false);
    mapState.addListener(_loadMarkers);
  }

  @override
  void dispose() {
    // // Remove the listeners to avoid memory leaks
    final mapState = Provider.of<MapState>(context, listen: false);
    mapState.removeListener(_loadMarkers);

    super.dispose();
    _isMounted = false;
  }

  @override
  Widget build(BuildContext context) {
    return _center == null
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Consumer<MapState>(
              builder: (context, mapState, child) {
                if (mapState.startLocation != null) {
                  _trips?.add(Marker(
                    markerId: const MarkerId('start'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    position: mapState.startLocation!,
                    infoWindow: const InfoWindow(title: 'Start Location'),
                  ));
                }
                if (mapState.endLocation != null) {
                  _trips?.add(Marker(
                    markerId: const MarkerId('end'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange),
                    position: mapState.endLocation!,
                    infoWindow: const InfoWindow(title: 'End Location'),
                  ));
                }

                double radiusInMeters = mapState.radius * 1609.34;

                if (!SingleUser().getUser()!.driver &&
                    mapState.endLocation != null) {
                  searchRadiusOverlay = {
                    Circle(
                      circleId: const CircleId('startCircle'),
                      center: mapState.endLocation!,
                      radius: radiusInMeters,
                      fillColor: Colors.blue.withOpacity(0.5),
                      strokeColor: Colors.blue,
                      strokeWidth: 2,
                    )
                  };
                }

                return GoogleMap(
                  markers: _trips ?? {},
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  initialCameraPosition:
                      CameraPosition(target: _center!, zoom: 11),
                  onMapCreated: _onMapCreated,
                  onLongPress: _handleLongPressRider,
                  circles: searchRadiusOverlay!,
                );
              },
            ),
          );
  }
}
