import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/bootstrap.dart';

Future<void> main() async {
  // Menyiapkan Flutter sebelum menjalankan widget pertama aplikasi.
  WidgetsFlutterBinding.ensureInitialized();

  // Membaca konfigurasi, memvalidasi, dan menginisialisasikan Supabase ke Flutter.
  await bootstrap();

  // UrbanHeatApp adalah akar seluruh pohon widget aplikasi.
  runApp(const UrbanHeatApp());
}
