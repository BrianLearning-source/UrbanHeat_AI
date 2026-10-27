import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class UrbanHeatApp extends StatelessWidget {
  const UrbanHeatApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router menghubungkan tema global dengan sistem routing go_router.
    return MaterialApp.router(
      title: 'UrbanHeat AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router ?? appRouter,
    );
  }
}
