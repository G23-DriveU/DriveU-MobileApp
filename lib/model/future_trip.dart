import 'dart:convert';
import 'package:driveu_mobile_app/model/app_user.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';

// Get a singular trip
FutureTrip futureTripFromJson(String str) =>
    FutureTrip.fromJson(json.decode(str));
String futureTripToJson(FutureTrip data) => json.encode(data.toJson());
// Get a list of future trips
List<FutureTrip> futureTripsFromJson(String str) =>
    List<FutureTrip>.from(json.decode(str).map((x) => FutureTrip.fromJson(x)));
String futureTripsToJson(List<FutureTrip> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// https://app.quicktype.io/ was used to generate the model class from the JSON response
class FutureTrip {
  int driverId;
  String startLocation;
  String destination;
  int startTime;
  bool avoidHighways;
  bool avoidTolls;
  bool roundTrip;
  int id;
  double startLocationLat;
  double startLocationLng;
  double destinationLat;
  double destinationLng;
  String eta;
  double distance;
  bool isFull;
  String ets;
  RideRequest? request;
  AppUser? driver;

  FutureTrip(
      {required this.driverId,
      required this.startLocation,
      required this.destination,
      required this.startTime,
      required this.avoidHighways,
      required this.avoidTolls,
      required this.roundTrip,
      required this.id,
      required this.startLocationLat,
      required this.startLocationLng,
      required this.destinationLat,
      required this.destinationLng,
      required this.eta,
      required this.distance,
      required this.isFull,
      required this.ets,
      required this.driver,
      this.request});

  factory FutureTrip.fromJson(Map<String, dynamic> json) => FutureTrip(
        driverId: json["driverId"],
        startLocation: json["startLocation"],
        destination: json["destination"],
        startTime: json["startTime"],
        avoidHighways: json["avoidHighways"],
        avoidTolls: json["avoidTolls"],
        roundTrip: json["roundTrip"],
        id: json["id"],
        startLocationLat: json["startLocationLat"]?.toDouble(),
        startLocationLng: json["startLocationLng"]?.toDouble(),
        destinationLat: json["destinationLat"]?.toDouble(),
        destinationLng: json["destinationLng"]?.toDouble(),
        eta: json["eta"],
        distance: json["distance"]?.toDouble(),
        isFull: json["isFull"],
        ets: json["ets"],
        request: json["rideRequest"] == null
            ? null
            : RideRequest.fromJson(json["rideRequest"]),
        driver:
            json["driver"] == null ? null : AppUser.fromJson(json["driver"]),
      );

  Map<String, dynamic> toJson() => {
        "driverId": driverId,
        "startLocation": startLocation,
        "destination": destination,
        "startTime": startTime,
        "avoidHighways": avoidHighways,
        "avoidTolls": avoidTolls,
        "roundTrip": roundTrip,
        "id": id,
        "startLocationLat": startLocationLat,
        "startLocationLng": startLocationLng,
        "destinationLat": destinationLat,
        "destinationLng": destinationLng,
        "eta": eta,
        "distance": distance,
        "isFull": isFull,
        "ets": ets,
      };
}
