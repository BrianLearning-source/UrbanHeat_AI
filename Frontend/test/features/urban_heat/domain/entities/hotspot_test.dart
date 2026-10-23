import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/features/urban_heat/domain/entities/hotspot.dart';

void main() {
  test('Hotspot retains its business fields', () {
    const hotspot = Hotspot(
      rank: 1,
      gridId: 'MC-204',
      title: 'Central Malang',
      district: 'Klojen',
      tag: 'High NDBI / Low NDVI',
      temp: 35.1,
      status: 'POTENTIAL HOTSPOT',
      riskLevel: 'HIGH',
    );

    expect(hotspot.rank, 1);
    expect(hotspot.gridId, 'MC-204');
    expect(hotspot.title, 'Central Malang');
    expect(hotspot.district, 'Klojen');
    expect(hotspot.tag, 'High NDBI / Low NDVI');
    expect(hotspot.temp, 35.1);
    expect(hotspot.status, 'POTENTIAL HOTSPOT');
    expect(hotspot.riskLevel, 'HIGH');
  });
}
