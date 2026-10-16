
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

Future<void> bootstrap() async {
  // 1. Memuat konfigurasi dari file .env.
  await dotenv.load(fileName: '.env');

  // 2. Memvalidasi konfigurasi.
  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'SUPABASE_URL atau SUPABASE_PUBLISHABLE_KEY belum diatur.',
    );
  }

  // 3. Menginisialisasi Supabase.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
}
