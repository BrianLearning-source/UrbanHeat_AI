import '../../../../core/failures.dart';
import '../entities/environmental_indicator.dart';
import '../entities/hotspot.dart';
import '../entities/mitigation.dart';
import '../entities/shap_dimension.dart';
import '../entities/shap_factor.dart';

/// Repository result contract: a successful call has data and no failure;
/// a failed call has a failure and no data.
typedef UrbanHeatResult<T> = ({T? data, Failure? failure});

/// Provides urban heat data to presentation without exposing its source.
abstract interface class UrbanHeatRepository {
  Future<UrbanHeatResult<List<Hotspot>>> getHotspots();

  Future<UrbanHeatResult<List<EnvironmentalIndicator>>> getAreaIndicators(
    String gridId,
  );

  Future<UrbanHeatResult<List<ShapFactor>>> getShapFactors(String gridId);

  Future<UrbanHeatResult<List<ShapDimension>>> getShapDimensions(String gridId);

  Future<UrbanHeatResult<List<Mitigation>>> getMitigations(String gridId);
}
