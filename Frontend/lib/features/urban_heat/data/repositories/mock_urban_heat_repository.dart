import '../../../../core/failures.dart';
import '../../domain/entities/environmental_indicator.dart';
import '../../domain/entities/hotspot.dart';
import '../../domain/entities/mitigation.dart';
import '../../domain/entities/shap_dimension.dart';
import '../../domain/entities/shap_factor.dart';
import '../../domain/repositories/urban_heat_repository.dart';
import '../mock_urban_heat_data.dart';

/// In-memory implementation used by the current prototype.
class MockUrbanHeatRepository implements UrbanHeatRepository {
  const MockUrbanHeatRepository();

  @override
  Future<UrbanHeatResult<List<Hotspot>>> getHotspots() async {
    return _read(() => MockUrbanHeatData.hotspots);
  }

  @override
  Future<UrbanHeatResult<List<EnvironmentalIndicator>>> getAreaIndicators(
    String gridId,
  ) async {
    // The current mock dataset only contains MC-204 indicators. The prototype
    // has historically shown this same fixed detail data for any selected ID.
    return _read(() => MockUrbanHeatData.indicatorsMC204);
  }

  @override
  Future<UrbanHeatResult<List<ShapFactor>>> getShapFactors(
    String gridId,
  ) async {
    return _read(() => MockUrbanHeatData.shapFactors);
  }

  @override
  Future<UrbanHeatResult<List<ShapDimension>>> getShapDimensions(
    String gridId,
  ) async {
    return _read(() => MockUrbanHeatData.shapDimensions);
  }

  @override
  Future<UrbanHeatResult<List<Mitigation>>> getMitigations(
    String gridId,
  ) async {
    return _read(() => MockUrbanHeatData.mitigations);
  }

  UrbanHeatResult<T> _read<T>(T Function() read) {
    try {
      return (data: read(), failure: null);
    } catch (_) {
      return (data: null, failure: const UnexpectedFailure());
    }
  }
}
