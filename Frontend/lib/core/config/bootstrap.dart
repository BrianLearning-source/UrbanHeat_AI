import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

Future<void> bootstrap() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint(
      'Supabase env file not found; running without remote config: $error',
    );
  }

  if (!SupabaseConfig.isConfigured) {
    debugPrint(
      'Supabase credentials are not configured. Falling back to local-only in-app state.',
    );
    return;
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  } catch (error) {
    debugPrint(
      'Supabase initialization failed. Falling back to local-only in-app state: $error',
    );
  }
}
