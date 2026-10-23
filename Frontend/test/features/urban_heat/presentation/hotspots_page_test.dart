import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/core/failures.dart';
import 'package:urbanheat_ai/features/urban_heat/domain/entities/environmental_indicator.dart';
import 'package:urbanheat_ai/features/urban_heat/domain/entities/hotspot.dart';
import 'package:urbanheat_ai/features/urban_heat/domain/entities/mitigation.dart';
import 'package:urbanheat_ai/features/urban_heat/domain/entities/shap_dimension.dart';
import 'package:urbanheat_ai/features/urban_heat/domain/entities/shap_factor.dart';
import 'package:urbanheat_ai/features/urban_heat/domain/repositories/urban_heat_repository.dart';
import 'package:urbanheat_ai/features/urban_heat/presentation/pages/hotspots_page.dart';

void main() {
  testWidgets('HotspotsPage renders entities from a successful repository', (
    tester,
  ) async {
    const repository = _FakeUrbanHeatRepository(
      hotspotsResult: (
        data: [
          Hotspot(
            rank: 1,
            gridId: 'MC-204',
            title: 'Central Malang',
            district: 'Klojen',
            tag: 'High NDBI / Low NDVI',
            temp: 35.1,
            status: 'POTENTIAL HOTSPOT',
            riskLevel: 'HIGH',
          ),
        ],
        failure: null,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: HotspotsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Potential Hotspots'), findsOneWidget);
    expect(find.text('Arterial Commercial Axis'), findsOneWidget);
  });

  testWidgets('HotspotsPage handles a repository failure', (tester) async {
    const repository = _FakeUrbanHeatRepository(
      hotspotsResult: (data: null, failure: NetworkFailure()),
    );

    await tester.pumpWidget(
      const MaterialApp(home: HotspotsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load hotspots.'), findsOneWidget);
  });
}

class _FakeUrbanHeatRepository implements UrbanHeatRepository {
  const _FakeUrbanHeatRepository({required this.hotspotsResult});

  final UrbanHeatResult<List<Hotspot>> hotspotsResult;

  @override
  Future<UrbanHeatResult<List<Hotspot>>> getHotspots() async => hotspotsResult;

  @override
  Future<UrbanHeatResult<List<EnvironmentalIndicator>>> getAreaIndicators(
    String gridId,
  ) async => (data: const <EnvironmentalIndicator>[], failure: null);

  @override
  Future<UrbanHeatResult<List<ShapFactor>>> getShapFactors(
    String gridId,
  ) async => (data: const <ShapFactor>[], failure: null);

  @override
  Future<UrbanHeatResult<List<ShapDimension>>> getShapDimensions(
    String gridId,
  ) async => (data: const <ShapDimension>[], failure: null);

  @override
  Future<UrbanHeatResult<List<Mitigation>>> getMitigations(
    String gridId,
  ) async => (data: const <Mitigation>[], failure: null);
}
