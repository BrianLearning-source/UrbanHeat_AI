import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/features/urban_heat/data/repositories/mock_urban_heat_repository.dart';

void main() {
  test(
    'MockUrbanHeatRepository returns hotspot entities successfully',
    () async {
      const repository = MockUrbanHeatRepository();

      final result = await repository.getHotspots();

      expect(result.failure, isNull);
      expect(result.data, isNotNull);
      expect(result.data, hasLength(3));
      expect(result.data!.first.gridId, 'MC-204');
    },
  );
}
