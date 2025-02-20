import 'dart:convert';

// NOTE: Firebase uid and FCM tokens are set to null since they are not immediately
// received upon the user registering first with Firebase. Because of this, they are
// delayed in getting them until we can ping Firebase for those things.

// Get a singular user
AppUser userFromJson(String str) => AppUser.fromJson(json.decode(str)['user']);
String userToJson(AppUser data) => json.encode(data.toJson());
// To get AppUsers from a list
List<AppUser> usersFromJson(String str) =>
    List<AppUser>.from(json.decode(str).map((x) => AppUser.fromJson(x)));
String usersToJson(List<AppUser> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// https://app.quicktype.io/ was used to generate the model class from the JSON response
class AppUser {
  String? firebaseUid;
  // TODO: Might change this to String to represent the base 64 encoded string
  dynamic profileImage;
  String name;
  String email;
  String phoneNumber;
  String school;
  String? fcmToken;
  bool driver;
  // Note that if the user IN NOT driving then capturing this information in the database is not necessary
  int? id;
  int? driverRating;
  int? driverReviewCount;
  int? riderRating;
  int? riderReviewCount;
  String? carColor;
  String? carPlate;
  String? carMake;
  String? carModel;
  int? carMpg;

  AppUser({
    this.firebaseUid,
    this.profileImage,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.school,
    this.fcmToken,
    required this.driver,
    this.id,
    this.driverRating,
    this.driverReviewCount,
    this.riderRating,
    this.riderReviewCount,
    this.carColor,
    this.carPlate,
    this.carMake,
    this.carModel,
    this.carMpg,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        firebaseUid: json["firebaseUid"],
        profileImage: json["profileImage"],
        name: json["name"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        school: json["school"],
        fcmToken: json["fcmToken"],
        driver: json["driver"],
        // IMPORTANT: This is need to make almost ALL requests for a user
        id: json["id"],
        driverRating: json["driverRating"],
        driverReviewCount: json["driverReviewCount"],
        riderRating: json["riderRating"],
        riderReviewCount: json["riderReviewCount"],
        carColor: json["carColor"],
        carPlate: json["carPlate"],
        carMake: json["carMake"],
        carModel: json["carModel"],
        carMpg: json["carMpg"],
      );
  Map<String, dynamic> toJson() => {
        "firebaseUid": firebaseUid,
        "profileImage": profileImage,
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
        "school": school,
        "fcmToken": fcmToken,
        "driver": driver,
        "id": id,
        "driverRating": driverRating,
        "driverReviewCount": driverReviewCount,
        "riderRating": riderRating,
        "riderReviewCount": riderReviewCount,
        "carColor": carColor,
        "carPlate": carPlate,
        "carMake": carMake,
        "carModel": carModel,
        "carMpg": carMpg,
      };
  Map<String, String> toQueryParams(String? auth) => {
        "firebaseUid": firebaseUid!,
        "profileImage": profileImage ?? "",
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
        "school": school,
        "fcmToken": fcmToken ?? "",
        "driver": driver.toString(),
        "carColor": carColor.toString(),
        "carPlate": carPlate.toString(),
        "carMake": carMake.toString(),
        "carModel": carModel.toString(),
        "carMpg": carMpg.toString(),
        "authCode": auth ?? ""
      };
  @override
  String toString() {
    return "firebaseUid: $firebaseUid, name: $name, email: $email, phoneNumber: $phoneNumber, school: $school, fcmToken: $fcmToken, driver: $driver, id: $id, driverRating: $driverRating, driverReviewCount: $driverReviewCount, riderRating: $riderRating, riderReviewCount: $riderReviewCount, carColor: $carColor, carPlate: $carPlate, carMake: $carMake, carModel: $carModel, carMpg: $carMpg";
  }
}
