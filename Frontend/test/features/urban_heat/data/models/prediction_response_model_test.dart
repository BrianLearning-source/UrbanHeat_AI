
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/features/urban_heat/data/models/prediction_response_model.dart';

void main() {
  group('PredictionResponseModel', () {
    test('maps API JSON response correctly', () {
      final json = {
        'location': {
          'latitude': -7.9797,
          'longitude': 112.6304,
        },
        'date': '2026-11-12',
        'predicted_lst_celsius': 34.64,
        'base_value_celsius': 30.5,
        'risk_level': 'ELEVATED',
        'factors': [
          {
            'feature': 'ndbi',
            'title': 'Built-up Surface Area',
            'value': 0.77,
            'contribution_celsius': 2.943,
            'percentage': 62,
            'direction': 'increase',
            'impact_label': '+62% impact',
          },
        ],
        'dimensions': [
          {
            'title': 'Built-up Surface',
            'subtitle': 'NDBI Index: 0.77',
            'badge': 'High Density',
            'description': 'Dense built-up surfaces retain heat.',
          },
        ],
        'mitigations': [
          {
            'category': 'Permeable Infrastructure',
            'title': 'Permeable Pavements',
            'target': 'Dense paved surfaces',
            'impact': 'NDBI adds about +2.9°C.',
            'description': 'Use permeable surfaces.',
            'badge': 'Recommended',
            'details': 'Consider porous pavers.',
            'category_code': 'permeable',
            'related_feature': 'ndbi',
          },
        ],
        'model_version': 'dummy-0.2',
        'is_dummy': true,
        'generated_at': '2026-11-12T03:25:41Z',
      };

      final result = PredictionResponseModel.fromJson(json);

      expect(result.latitude, -7.9797);
      expect(result.longitude, 112.6304);
      expect(result.predictedLstCelsius, 34.64);
      expect(result.baseValueCelsius, 30.5);
      expect(result.riskLevel, 'ELEVATED');

      expect(result.factors.length, 1);
      expect(result.factors.first.feature, 'ndbi');
      expect(result.factors.first.percentage, 62);

      expect(result.dimensions.length, 1);
      expect(result.dimensions.first.title, 'Built-up Surface');

      expect(result.mitigations.length, 1);
      expect(result.mitigations.first.categoryCode, 'permeable');

      expect(result.modelVersion, 'dummy-0.2');
      expect(result.isDummy, isTrue);
    });
  });
}
