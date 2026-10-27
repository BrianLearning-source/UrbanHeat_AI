import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/bootstrap.dart';

Future<void> main() async {
  // Menyiapkan Flutter sebelum menjalankan widget pertama aplikasi.
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = FlutterError.dumpErrorToConsole;
  ErrorWidget.builder = (details) => Material(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('A screen error occurred:\n${details.exceptionAsString()}'),
      ),
    ),
  );

  // Membaca konfigurasi, memvalidasi, dan menginisialisasikan Supabase ke Flutter.
  try {
    await bootstrap();
    runApp(const UrbanHeatApp());
  } catch (error, stackTrace) {
    debugPrint('UrbanHeat AI startup failed. See the stack trace for details.');
    debugPrintStack(stackTrace: stackTrace);
    runApp(const _StartupErrorApp());
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanHeat AI startup error',
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'UrbanHeat AI could not start. Check the Supabase '
                'configuration and try again.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
