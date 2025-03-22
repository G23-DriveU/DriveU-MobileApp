import 'dart:convert';
import 'package:driveu_mobile_app/model/app_user.dart';

PastTrip pastTripFromJson(String str) => PastTrip.fromJson(json.decode(str));
List<PastTrip> pastTripsFromJson(String str) =>
    List<PastTrip>.from(json.decode(str).map((x) => PastTrip.fromJson(x)));
String pastTripToJson(PastTrip data) => json.encode(data.toJson());

class PastTrip {
  int driverId;
  int riderId;
  String startLocation;
  double startLocationLat;
  double startLocationLng;
  String riderLocation;
  double riderLocationLat;
  double riderLocationLng;
  String destination;
  double destinationLat;
  double destinationLng;
  bool roundTrip;
  double driverPayout;
  double riderCost;
  double distance;
  int id;
  AppUser? rider;
  AppUser? driver;

  PastTrip({
    required this.driverId,
    required this.riderId,
    required this.startLocation,
    required this.startLocationLat,
    required this.startLocationLng,
    required this.riderLocation,
    required this.riderLocationLat,
    required this.riderLocationLng,
    required this.destination,
    required this.destinationLat,
    required this.destinationLng,
    required this.roundTrip,
    required this.driverPayout,
    required this.riderCost,
    required this.distance,
    required this.id,
    this.rider,
    this.driver,
  });

  factory PastTrip.fromJson(Map<String, dynamic> json) => PastTrip(
        driverId: json["driverId"],
        riderId: json["riderId"],
        startLocation: json["startLocation"],
        startLocationLat: json["startLocationLat"]?.toDouble(),
        startLocationLng: json["startLocationLng"]?.toDouble(),
        riderLocation: json["riderLocation"],
        riderLocationLat: json["riderLocationLat"]?.toDouble(),
        riderLocationLng: json["riderLocationLng"]?.toDouble(),
        destination: json["destination"],
        destinationLat: json["destinationLat"]?.toDouble(),
        destinationLng: json["destinationLng"]?.toDouble(),
        roundTrip: json["roundTrip"],
        driverPayout: json["driverPayout"]?.toDouble(),
        riderCost: json["riderCost"]?.toDouble(),
        distance: json["distance"]?.toDouble(),
        id: json["id"],
        rider: json.containsKey("rider") && json["rider"] != null
            ? AppUser.fromJson(json["rider"])
            : null,
        driver: json.containsKey("driver") && json["driver"] != null
            ? AppUser.fromJson(json["driver"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "driverId": driverId,
        "riderId": riderId,
        "startLocation": startLocation,
        "startLocationLat": startLocationLat,
        "startLocationLng": startLocationLng,
        "riderLocation": riderLocation,
        "riderLocationLat": riderLocationLat,
        "riderLocationLng": riderLocationLng,
        "destination": destination,
        "destinationLat": destinationLat,
        "destinationLng": destinationLng,
        "roundTrip": roundTrip,
        "driverPayout": driverPayout,
        "riderCost": riderCost,
        "distance": distance,
        "id": id,
        "driver": driver?.toJson() ?? "",
        "rider": rider?.toJson() ?? ""
      };
}
