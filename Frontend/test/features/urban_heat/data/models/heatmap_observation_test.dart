import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/features/urban_heat/data/models/heatmap_observation.dart';

void main() {
  group('HeatmapObservation.tryParse', () {
    test('parses valid coordinates and numeric observation values', () {
      final observation = HeatmapObservation.tryParse({
        'id': 12,
        'date': '2024-06-08',
        'latitude': '-7.95',
        'longitude': 112.63,
        'lst': 31.7,
        'ndvi': null,
      });

      expect(observation, isNotNull);
      expect(observation!.id, 12);
      expect(observation.dateKey, '2024-06-08');
      expect(observation.latitude, -7.95);
      expect(observation.longitude, 112.63);
      expect(observation.lst, 31.7);
      expect(observation.ndvi, isNull);
    });

    test('rejects missing required values and out-of-range coordinates', () {
      final invalidRows = [
        {
          'id': 1,
          'date': '2024-06-08',
          'latitude': null,
          'longitude': 112.63,
          'lst': 31.7,
        },
        {
          'id': 2,
          'date': '2024-06-08',
          'latitude': 91,
          'longitude': 112.63,
          'lst': 31.7,
        },
        {
          'id': 3,
          'date': '2024-06-08',
          'latitude': -7.95,
          'longitude': 181,
          'lst': 31.7,
        },
        {
          'id': 4,
          'date': 'invalid-date',
          'latitude': -7.95,
          'longitude': 112.63,
          'lst': 31.7,
        },
      ];

      for (final row in invalidRows) {
        expect(HeatmapObservation.tryParse(row), isNull);
      }
    });
  });
}
