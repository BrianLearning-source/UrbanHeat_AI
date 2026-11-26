
import 'dart:io';

import 'package:urbanheat_ai/core/network/api_client.dart';
import 'package:urbanheat_ai/features/urban_heat/data/repositories/api_prediction_repository.dart';

Future<void> main() async {
  const latitude = -7.9797;
  const longitude = 112.6304;
  final date = DateTime(2026, 11, 12);

  final repository = ApiPredictionRepository(
    ApiClient(
      baseUrl: 'http://127.0.0.1:8000',
    ),
  );

  stdout.writeln('Sending prediction request to FastAPI...');

  final result = await repository.predict(
    latitude: latitude,
    longitude: longitude,
    date: date,
  );

  if (result.failure != null) {
    stderr.writeln('Prediction request failed.');
    stderr.writeln('Failure: ${result.failure}');
    exitCode = 1;
    return;
  }

  final prediction = result.data;

  if (prediction == null) {
    stderr.writeln('Prediction response is empty.');
    exitCode = 1;
    return;
  }

  stdout.writeln('\nPrediction API integration successful!');
  stdout.writeln('Latitude: ${prediction.latitude}');
  stdout.writeln('Longitude: ${prediction.longitude}');
  stdout.writeln('Date: ${prediction.date}');
  stdout.writeln('Predicted LST: ${prediction.predictedLstCelsius} °C');
  stdout.writeln('Base Value: ${prediction.baseValueCelsius} °C');
  stdout.writeln('Risk Level: ${prediction.riskLevel}');
  stdout.writeln('Model Version: ${prediction.modelVersion}');
  stdout.writeln('Is Dummy: ${prediction.isDummy}');
  stdout.writeln('Generated At: ${prediction.generatedAt}');

  if (!prediction.isDummy) {
    stderr.writeln('Warning: Expected DummyPredictor response.');
    exitCode = 1;
  }
}
