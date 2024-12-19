import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';

class UserApi {
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
}
