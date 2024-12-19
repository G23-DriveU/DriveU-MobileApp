import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:http/http.dart' as http;

// Make a singleton class to enable users to make http requests
class SingleClient {
  SingleClient._privateConstructor();

  static final SingleClient _instance = SingleClient._privateConstructor();

  factory SingleClient() {
    return _instance;
  }

  final http.Client client = http.Client();

  // Enable all CRUD operation that are required
  Future<http.Response> post(String url,
      {Map<String, String>? queryParameters}) async {
    return await client.post(
        Uri.parse(makeUrl(url)).replace(queryParameters: queryParameters));
  }

  Future<http.Response> get(String url,
      {Map<String, String>? queryParameters}) async {
    return await client
        .get(Uri.parse(makeUrl(url)).replace(queryParameters: queryParameters));
  }

  Future<http.Response> put(String url,
      {Map<String, String>? queryParameters}) async {
    return await client
        .put(Uri.parse(makeUrl(url)).replace(queryParameters: queryParameters));
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? queryParameters}) async {
    return await client.delete(
        Uri.parse(makeUrl(url)).replace(queryParameters: queryParameters));
  }

  String makeUrl(String url) {
    return "$BASE_URL$url";
  }

  // Form the query parameters to send
  Map<String, String> makeQueryParameters(
      List<String> keys, List<String> values) {
    Map<String, String> queryParameters = {};
    for (int i = 0; i < keys.length; i++) {
      queryParameters[keys[i]] = values[i];
    }
    return queryParameters;
  }

  void close() {
    client.close();
  }
}
