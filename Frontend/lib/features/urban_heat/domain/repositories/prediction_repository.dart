import '../../../../core/failures.dart';
import '../entities/prediction.dart';

typedef PredictionResult = ({
  Prediction? data,
  Failure? failure,
});

abstract interface class PredictionRepository {
  Future<PredictionResult> predict({
    required double latitude,
    required double longitude,
    required DateTime date,
  });
}