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
  String? _notifyReason;

  get notifyReason => _notifyReason;

  get radius => _radius;
  setRadius(value) {
    _radius = value;
    _notifyReason = "radiusChanged";
    notifyListeners();
  }

  get wantRoundTrip => _wantRoundTrip;
  setWantRoundTrip(value) {
    _wantRoundTrip = value;
    _notifyReason = "roundTripChanged";
    notifyListeners();
  }

  get startLocation => _startLocation;
  setStartLocation(value) {
    _startLocation = value;
    _notifyReason = "locationChanged";
    notifyListeners();
  }

  get endLocation => _endLocation;
  setEndLocation(value) {
    _endLocation = value;
    _notifyReason = "locationChanged";
    notifyListeners();
  }

  get tripDateTime => _tripDateTime;
  setTripDateTime(value) {
    _tripDateTime = value;
    _notifyReason = "changedTripDate";
    notifyListeners();
  }

  Set<Marker> get markers => _markers;
  void addMarker(Marker marker) {
    _notifyReason = "addedMarker";
    _markers.add(marker);
    notifyListeners();
  }

  void setMarkers(Set<Marker> markers) {
    _markers = markers;
    _notifyReason = "setMarker";
    notifyListeners();
  }
}
