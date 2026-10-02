import 'package:http/http.dart' as http;

/// The single long-lived HTTP client shared by application API services.
class AppHttpClient {
  AppHttpClient._();

  static final AppHttpClient instance = AppHttpClient._();

  final http.Client client = http.Client();
}
