import '../../../../core/failures.dart';
import '../entities/heat_intensity_summary.dart';

typedef HeatIntensityResult = ({
  HeatIntensitySummary? data,
  Failure? failure,
});

abstract interface class HeatIntensityRepository {
  Future<HeatIntensityResult> getSummary();
}