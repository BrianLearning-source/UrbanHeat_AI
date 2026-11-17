import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../../../core/network/api_client.dart';

import '../../domain/repositories/heat_intensity_repository.dart';
import '../models/heat_intensity_summary_model.dart';

class ApiHeatIntensityRepository
    implements HeatIntensityRepository {
  ApiHeatIntensityRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HeatIntensityResult> getSummary() async {
    try {
      final response = await _apiClient.get(
        '/v1/heat-intensity/summary',
      );

      final model =
          HeatIntensitySummaryModel.fromJson(response);

      return (
        data: model.toEntity(),
        failure: null,
      );
    } on DioException {
      return (
        data: null,
        failure: const NetworkFailure(),
      );
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(),
      );
    }
  }
}
