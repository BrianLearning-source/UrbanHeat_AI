import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/app/app.dart';
import 'package:urbanheat_ai/app/router.dart';

void main() {
  testWidgets('UrbanHeat AI initial smoke and navigation test', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    appRouter.go('/home');
    await tester.pumpWidget(const UrbanHeatApp());
    await tester.pumpAndSettle();

    // 1. Start the smoke flow at Home, where the navigation test begins.
    expect(find.text('Good morning, Nasywa'), findsOneWidget);
    expect(find.text('City-wide Heat\nOutlook (Kota\nMalang)'), findsOneWidget);

    // Scroll to and tap "Explore City Heatmap →" -> /heatmap
    final exploreHeatmapFinder = find.text('Explore City Heatmap →');
    await tester.ensureVisible(exploreHeatmapFinder);
    await tester.pumpAndSettle();
    await tester.tap(exploreHeatmapFinder);
    await tester.pumpAndSettle();
    expect(find.text('City Heatmap'), findsOneWidget);
    expect(find.text('Heatmap akan diimplementasikan'), findsOneWidget);

    // 2. Navigate to Prediction Result (/heatmap/prediction)
    appRouter.go('/heatmap/prediction');
    await tester.pumpAndSettle();
    expect(find.text('Prediction Result'), findsOneWidget);
    expect(find.text('XGBoost Spatio-Temporal Regressor'), findsOneWidget);

    // Scroll to and tap "View Detailed Analysis →" -> /hotspots/area/LW-A12/factors
    final viewDetailedFinder = find.text('View Detailed Analysis →');
    await tester.ensureVisible(viewDetailedFinder);
    await tester.pumpAndSettle();
    await tester.tap(viewDetailedFinder);
    await tester.pumpAndSettle();
    expect(find.text('Contributing Factors'), findsOneWidget);
    expect(find.text('Built-up Surface Area'), findsOneWidget);

    // Scroll to and tap "Explore Mitigation Insights →" -> /hotspots/area/LW-A12/mitigation
    final exploreMitigationFinder = find.text('Explore Mitigation Insights →');
    await tester.ensureVisible(exploreMitigationFinder);
    await tester.pumpAndSettle();
    await tester.tap(exploreMitigationFinder);
    await tester.pumpAndSettle();
    expect(find.text('Suggested Mitigation\nMeasures'), findsOneWidget);

    // Scroll to and tap "Export Planning Summary (PDF)" -> SnackBar "Coming soon"
    final exportPdfFinder = find.text('Export Planning Summary (PDF)');
    await tester.ensureVisible(exportPdfFinder);
    await tester.pumpAndSettle();
    await tester.tap(exportPdfFinder);
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);

    // Tap "Back to Heatmap" -> /heatmap
    final backToHeatmapFinder = find.text('Back to Heatmap');
    await tester.ensureVisible(backToHeatmapFinder);
    await tester.pumpAndSettle();
    await tester.tap(backToHeatmapFinder);
    await tester.pumpAndSettle();
    expect(find.text('City Heatmap'), findsOneWidget);

    // 3. Navigate to Hotspots tab (/hotspots)
    appRouter.go('/hotspots');
    await tester.pumpAndSettle();
    expect(find.text('Potential Hotspots'), findsOneWidget);

    // Tap the available "View on Heatmap" action -> /heatmap
    final viewOnHeatmapFinder = find.text('View on Heatmap');
    await tester.ensureVisible(viewOnHeatmapFinder);
    await tester.pumpAndSettle();
    await tester.tap(viewOnHeatmapFinder);
    await tester.pumpAndSettle();
    expect(find.text('City Heatmap'), findsOneWidget);

    // 4. Navigate to Area Detail (/hotspots/area/MC-204)
    appRouter.go('/hotspots/area/MC-204');
    await tester.pumpAndSettle();
    expect(find.text('Area Detail'), findsOneWidget);
    expect(find.text('Grid #MC-204 · Central'), findsOneWidget);

    // Scroll to and tap the SHAP link -> factors
    final modelInfoFinder = find.text('Tap to view feature impact (SHAP) →');
    await tester.ensureVisible(modelInfoFinder);
    await tester.pumpAndSettle();
    await tester.tap(modelInfoFinder);
    await tester.pumpAndSettle();
    expect(find.text('Contributing Factors'), findsOneWidget);

    // 5. Navigate to Profile tab (/profile)
    appRouter.go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('Nasywa'), findsOneWidget);
    expect(find.text('Project Information'), findsOneWidget);
  });
}
