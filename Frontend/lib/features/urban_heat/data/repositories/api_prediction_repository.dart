
import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../models/prediction_response_model.dart';

class ApiPredictionRepository implements PredictionRepository {
  ApiPredictionRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PredictionResult> predict({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final response = await _apiClient.post(
        '/v1/predict',
        body: {
          'latitude': latitude,
          'longitude': longitude,
          'date': date.toIso8601String().split('T').first,
        },
      );

      final model = PredictionResponseModel.fromJson(response);

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
