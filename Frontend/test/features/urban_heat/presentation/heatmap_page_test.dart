import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/features/urban_heat/data/models/heatmap_observation.dart';
import 'package:urbanheat_ai/features/urban_heat/data/repositories/supabase_heatmap_repository.dart';
import 'package:urbanheat_ai/features/urban_heat/presentation/pages/heatmap_page.dart';

void main() {
  testWidgets('shows an honest point map for stored Supabase observations', (
    tester,
  ) async {
    final repository = _FakeHeatmapRepository([
      HeatmapObservation(
        id: 1,
        date: DateTime.utc(2024, 6, 8),
        latitude: -7.95,
        longitude: 112.63,
        lst: 31.7,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: HeatmapPage(repository: repository)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Stored observation points'), findsOneWidget);
    expect(
      find.text('Relative numeric lst value (unit unknown)'),
      findsOneWidget,
    );
    expect(find.text('31.70 (unit unknown)'), findsOneWidget);
    expect(find.text('Supabase · malang_climate_pilot.lst'), findsOneWidget);
    expect(find.text('Observation, not prediction'), findsOneWidget);
    expect(
      find.textContaining('Last observation date: 08 Jun 2024.'),
      findsOneWidget,
    );
    expect(find.textContaining('°C'), findsNothing);
  });

  testWidgets('shows an explicit empty state when no rows are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HeatmapPage(repository: _FakeHeatmapRepository([]))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No mappable observations'), findsOneWidget);
    expect(find.textContaining('malang_climate_pilot'), findsOneWidget);
    expect(find.byType(FlutterMap), findsNothing);
  });
}

class _FakeHeatmapRepository implements HeatmapObservationRepository {
  const _FakeHeatmapRepository(this.observations);

  final List<HeatmapObservation> observations;

  @override
  Future<List<HeatmapObservation>> getObservations() async => observations;
}
