import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/app/app.dart';
import 'package:urbanheat_ai/app/router.dart';

void main() {
  testWidgets('UrbanHeat AI initial smoke and navigation test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const UrbanHeatApp());
    await tester.pumpAndSettle();

    // 1. Verify Home Screen is initially active
    expect(find.text('UrbanHeat AI'), findsWidgets);
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

    // Scroll to and tap "Select on Heatmap to View Area Detail" -> /heatmap
    final selectOnHeatmapFinder = find.text('Select on Heatmap to View Area Detail');
    await tester.ensureVisible(selectOnHeatmapFinder);
    await tester.pumpAndSettle();
    await tester.tap(selectOnHeatmapFinder);
    await tester.pumpAndSettle();
    expect(find.text('City Heatmap'), findsOneWidget);

    // 4. Navigate to Area Detail (/hotspots/area/MC-204)
    appRouter.go('/hotspots/area/MC-204');
    await tester.pumpAndSettle();
    expect(find.text('Area Detail'), findsOneWidget);
    expect(find.text('GRID #MC-204 • CENTRAL'), findsOneWidget);

    // Scroll to and tap "Prediction & Model Info" -> factors
    final modelInfoFinder = find.text('Prediction & Model Info');
    await tester.ensureVisible(modelInfoFinder);
    await tester.pumpAndSettle();
    await tester.tap(modelInfoFinder);
    await tester.pumpAndSettle();
    expect(find.text('Contributing Factors'), findsOneWidget);

    // 5. Navigate to Profile tab (/profile)
    appRouter.go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('Nasywa'), findsOneWidget);
    expect(find.text('About the Project'), findsOneWidget);

    // Scroll to and tap "Clear Cache" -> SnackBar
    final clearCacheFinder = find.text('Clear Cache');
    await tester.ensureVisible(clearCacheFinder);
    await tester.pumpAndSettle();
    await tester.tap(clearCacheFinder);
    await tester.pump();
    expect(find.text('Offline inference cache cleared'), findsOneWidget);
  });
}
