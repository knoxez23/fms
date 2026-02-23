import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/crop_aggregate.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/crop_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';

void main() {
  test('rejects expected harvest before planted date', () {
    expect(
      () => CropAggregate(
        CropEntity(
          name: CropName('Maize'),
          plantedAt: DateTime(2025, 1, 10),
          expectedHarvest: DateTime(2025, 1, 1),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('daysToHarvest and harvest window are computed', () {
    final aggregate = CropAggregate(
      CropEntity(
        name: CropName('Maize'),
        plantedAt: DateTime(2025, 1, 1),
        expectedHarvest: DateTime(2025, 2, 1),
      ),
    );

    expect(
      aggregate.daysToHarvest(referenceDate: DateTime(2025, 1, 25)),
      7,
    );
    expect(
      aggregate.isHarvestWindowOpen(referenceDate: DateTime(2025, 1, 25)),
      isTrue,
    );
  });

  test('rescheduleHarvest enforces plantedAt bound', () {
    final aggregate = CropAggregate(
      CropEntity(
        name: CropName('Beans'),
        plantedAt: DateTime(2025, 3, 1),
        expectedHarvest: DateTime(2025, 4, 1),
      ),
    );

    expect(
      () => aggregate.rescheduleHarvest(DateTime(2025, 2, 28)),
      throwsArgumentError,
    );
  });
}
