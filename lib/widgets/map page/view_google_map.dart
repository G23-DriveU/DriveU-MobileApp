import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/google_maps_utils.dart';
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

// TODO: Change the behvaior for both rider and driver.
class _ViewGoogleMapState extends State<ViewGoogleMap> {
  // Manipulate the camera
  late GoogleMapController mapController;
  LatLng? _center;
  LocationData? _userPosition;
  Set<Marker>? _trips;
  Set<Circle>? searchRadiusOverlay = {};
  // Used to cancel async execution after navigation off of this screen
  bool _isMounted = true;
  // Need to safely listen and unsubscribe from MapState changes
  late MapState _mapState;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _handleLongPressRider(LatLng position) {
    if (_isMounted) {
      final mapState = Provider.of<MapState>(context, listen: false);

      setState(() {
        if (mapState.startLocation == null) {
          // Set the start location (pickup location)
          mapState.setStartLocation(position);
          // Retrieve trips with updated pricing
          _loadMarkers();
        } else {
          // Set the end location (used for the search radius circle)
          mapState.setEndLocation(position);
          // No need to reload trips, just update the circle
          _updateSearchRadiusOverlay();
        }
      });
    }
  }

  void _updateSearchRadiusOverlay() {
    if (_isMounted) {
      final mapState = Provider.of<MapState>(context, listen: false);

      if (mapState.endLocation != null) {
        double radiusInMeters =
            mapState.radius * 1609.34; // Convert miles to meters

        setState(() {
          searchRadiusOverlay = {
            Circle(
              circleId: const CircleId('searchRadius'),
              center: mapState.endLocation!,
              radius: radiusInMeters,
              fillColor: Colors.blue.withOpacity(0.5),
              strokeColor: Colors.blue,
              strokeWidth: 2,
            ),
          };
        });
      }
    }
  }

  // Retrieves a set of markers of future trips. For riders, they see a set of
  // future trips to join. For drivers, they see a set of future trips they have planned.
  void _loadMarkers() async {
    if (_isMounted) {
      final mapState = Provider.of<MapState>(context, listen: false);

      // Determine the API parameters based on the user's role
      final markers = SingleUser().getUser()!.driver
          ? await TripApi().getTrips({
              'driverId': SingleUser().getUser()!.id.toString(),
            }, context, _showTripInfo)
          : await TripApi().getTrips({
              'riderId': SingleUser().getUser()!.id.toString(),
              'radius': mapState.radius.toString(),
              'lat': mapState.endLocation?.latitude.toString() ??
                  _center!.latitude.toString(),
              'lng': mapState.endLocation?.longitude.toString() ??
                  _center!.longitude.toString(),
              'roundTrip': mapState.wantRoundTrip.toString(),
              'riderLat': mapState.startLocation?.latitude.toString() ??
                  _userPosition!.latitude!.toString(),
              'riderLng': mapState.startLocation?.longitude.toString() ??
                  _userPosition!.longitude!.toString(),
            }, context, _showTripInfo);
      if (_isMounted) {
        setState(() {
          _trips = markers;
          mapState.setMarkers(markers);
        });
      }
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
        _center = mapState.endLocation ??
            LatLng(userPostion.latitude!, userPostion.longitude!);
        mapState.setEndLocation(_center);
        mapState.setStartLocation(_center);
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
    // Get the current user's location and then load the markers
    _getUserLocation().then((_) {
      if (_center != null) {
        _loadMarkers();
      }
    });

    // Add a listener to the MapState to reload markers when the radius changes
    _mapState = Provider.of<MapState>(context, listen: false);
    _mapState.addListener(() {
      _loadMarkers();
      _updateSearchRadiusOverlay();
    });
  }

  @override
  void dispose() {
    // Remove the listeners to avoid memory leaks
    _mapState.removeListener(_loadMarkers);
    _isMounted = false;
    super.dispose();
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
                if (!SingleUser().getUser()!.driver) {
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
                }

                return GoogleMap(
                  markers: mapState.markers,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: mapState.endLocation ?? _center!, zoom: 11),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    LatLngBounds bounds = GoogleMapsUtils().calculateBounds(
                      mapState.markers
                          .map((marker) => marker.position)
                          .toList(),
                    );
                    mapController.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 50),
                    );
                  },
                  // Only the riders can change the start and end location by long pressing
                  onLongPress: SingleUser().getUser()!.driver
                      ? null
                      : _handleLongPressRider,
                  // Only riders see the search radius
                  circles: SingleUser().getUser()!.driver
                      ? {}
                      : searchRadiusOverlay ?? {},
                );
              },
            ),
          );
  }
}
