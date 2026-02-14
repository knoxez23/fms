import '../value_objects/value_objects.dart';

class CropEntity {
  final String? id;
  final CropName name;
  final String? variety;
  final DateTime? plantedAt;
  final DateTime? expectedHarvest;

  CropEntity({
    this.id,
    required this.name,
    this.variety,
    this.plantedAt,
    this.expectedHarvest,
  });

  bool get isReadyForHarvest {
    if (expectedHarvest == null) return false;
    return DateTime.now().isAfter(expectedHarvest!);
  }
}
