
import '../../domain/entities/heat_intensity_summary.dart';
import '../../domain/repositories/heat_intensity_repository.dart';

class MockHeatIntensityRepository
    implements HeatIntensityRepository {
  const MockHeatIntensityRepository();

  @override
  Future<HeatIntensityResult> getSummary() async {
    return (
      data: HeatIntensitySummary(
        scope: 'CITY_WIDE',
        areaName: 'Kota Malang',

        lstCelsius: 33.4,
        intensityLevel: HeatIntensityLevel.moderate,

        lowerThresholdCelsius: 28.0,
        higherThresholdCelsius: 34.0,

        scaleMinCelsius: 24.0,
        scaleMaxCelsius: 40.0,

        modelVersion: 'mock-test-0.1',
        source: 'dummy',
        isDummy: true,

        generatedAt: DateTime.utc(2026, 11, 16),
      ),
      failure: null,
    );
  }
}
