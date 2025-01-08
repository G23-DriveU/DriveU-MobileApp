import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/model/app_user.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';

class UserApi {
  // Create a new user to the application
  Future<String?> createUser(Map<String, String> queryParameters) async {
    try {
      final response =
          await SingleClient().post(USER, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        return null;
      } else {
        return response.body;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // For existing users, retrieve their user data from the database
  static Future<AppUser?> getUser(Map<String, String> queryParameters) async {
    try {
      final response =
          await SingleClient().get(USER, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return userFromJson(response.body);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      return null;
    }
  }
}
