import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/core/config/supabase_config.dart';

void main() {
  tearDown(dotenv.clean);

  test('accepts a configured Supabase URL and publishable key', () {
    dotenv.loadFromString(
      envString:
          'SUPABASE_URL=https://example.supabase.co\n'
          'SUPABASE_PUBLISHABLE_KEY=sb_publishable_test',
    );

    expect(SupabaseConfig.isConfigured, isTrue);
    expect(SupabaseConfig.url, 'https://example.supabase.co');
  });

  test('rejects missing and example placeholder configuration', () {
    dotenv.loadFromString(
      envString: 'SUPABASE_URL=\nSUPABASE_PUBLISHABLE_KEY=',
    );
    expect(SupabaseConfig.isConfigured, isFalse);

    dotenv.loadFromString(
      envString:
          'SUPABASE_URL=https://your-project.supabase.co\n'
          'SUPABASE_PUBLISHABLE_KEY=your-supabase-publishable-key',
    );

    expect(SupabaseConfig.isConfigured, isFalse);
  });

  test('rejects URLs containing user info or query parameters', () {
    dotenv.loadFromString(
      envString:
          'SUPABASE_URL=https://user@example.supabase.co?mode=invalid\n'
          'SUPABASE_PUBLISHABLE_KEY=sb_publishable_test',
    );

    expect(SupabaseConfig.isConfigured, isFalse);
  });
}
