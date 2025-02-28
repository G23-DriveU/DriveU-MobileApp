import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';

class PayPalApi {
  Future<String?> getPayUrl(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .get(CREATE_PAYPAL_ORDER, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      print("There was some error: ${e.toString()}");
      return null;
    }
  }
}
