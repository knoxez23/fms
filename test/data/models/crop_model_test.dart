import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/data/models/crop.dart';

void main() {
  test('Crop.fromMap parses numeric strings safely', () {
    final crop = Crop.fromMap({
      'id': '12',
      'name': 'Maize',
      'planted_date': '2026-02-01',
      'expected_harvest_date': '2026-06-01',
      'area': '1.75',
      'status': 'growing',
    });

    expect(crop.id, 12);
    expect(crop.area, 1.75);
    expect(crop.status, 'growing');
  });
}

