import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState with ChangeNotifier {
  // For rider
  double _radius = 5.0;
  bool _wantRoundTrip = false;
  // For driver
  LatLng? _startLocation;
  LatLng? _endLocation;
  DateTime? _tripDateTime;
  Set<Marker> _markers = {};

  get radius => _radius;
  setRadius(value) {
    _radius = value;
    notifyListeners();
  }

  get wantRoundTrip => _wantRoundTrip;
  setWantRoundTrip(value) {
    _wantRoundTrip = value;
    notifyListeners();
  }

  get startLocation => _startLocation;
  setStartLocation(value) {
    _startLocation = value;
    notifyListeners();
  }

  get endLocation => _endLocation;
  setEndLocation(value) {
    _endLocation = value;
    notifyListeners();
  }

  get tripDateTime => _tripDateTime;
  setTripDateTime(value) {
    _tripDateTime = value;
    notifyListeners();
  }

  Set<Marker> get markers => _markers;
  void addMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void setMarkers(Set<Marker> markers) {
    _markers = markers;
    notifyListeners();
  }
}
