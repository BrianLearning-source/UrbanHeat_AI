import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url => (dotenv.env['SUPABASE_URL'] ?? '').trim();

  static String get publishableKey =>
      (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '').trim();

  static bool get isConfigured {
    final parsedUrl = Uri.tryParse(url);
    return parsedUrl != null &&
        (parsedUrl.scheme == 'https' || parsedUrl.scheme == 'http') &&
        parsedUrl.host.isNotEmpty &&
        parsedUrl.userInfo.isEmpty &&
        !parsedUrl.hasQuery &&
        !parsedUrl.hasFragment &&
        !url.toLowerCase().contains('your-project') &&
        publishableKey.isNotEmpty &&
        !publishableKey.toLowerCase().startsWith('your-');
  }
}
