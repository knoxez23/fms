import 'crop_entity.dart';

class CropAggregate {
  final CropEntity crop;

  CropAggregate(this.crop) {
    _validate(crop);
  }

  void _validate(CropEntity value) {
    final plantedAt = value.plantedAt;
    final expectedHarvest = value.expectedHarvest;
    if (plantedAt != null &&
        expectedHarvest != null &&
        expectedHarvest.isBefore(plantedAt)) {
      throw ArgumentError(
        'Expected harvest date cannot be before planted date',
      );
    }
  }

  int? daysToHarvest({DateTime? referenceDate}) {
    final expectedHarvest = crop.expectedHarvest;
    if (expectedHarvest == null) return null;
    final ref = referenceDate ?? DateTime.now();
    return expectedHarvest.difference(ref).inDays;
  }

  bool isHarvestWindowOpen({
    DateTime? referenceDate,
    int windowDays = 7,
  }) {
    final days = daysToHarvest(referenceDate: referenceDate);
    if (days == null) return false;
    return days <= windowDays;
  }

  CropEntity rescheduleHarvest(DateTime newExpectedHarvest) {
    final plantedAt = crop.plantedAt;
    if (plantedAt != null && newExpectedHarvest.isBefore(plantedAt)) {
      throw ArgumentError(
        'Expected harvest date cannot be before planted date',
      );
    }
    return CropEntity(
      id: crop.id,
      name: crop.name,
      variety: crop.variety,
      plantedAt: crop.plantedAt,
      expectedHarvest: newExpectedHarvest,
      area: crop.area,
      status: crop.status,
      notes: crop.notes,
    );
  }
}
