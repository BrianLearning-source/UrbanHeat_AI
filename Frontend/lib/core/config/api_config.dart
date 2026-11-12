import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl => (dotenv.env['API_BASE_URL'] ?? '').trim();

  static bool get isConfigured {
    final uri = Uri.tryParse(baseUrl);

    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty && uri.userInfo.isEmpty && !uri.hasQuery && !uri.hasFragment;
  }
}
