import '../value_objects/value_objects.dart';

class CropEntity {
  final String? id;
  final CropName name;
  final String? variety;
  final DateTime? plantedAt;
  final DateTime? expectedHarvest;
  final double? area;
  final String? status;
  final String? notes;

  CropEntity({
    this.id,
    required this.name,
    this.variety,
    this.plantedAt,
    this.expectedHarvest,
    this.area,
    this.status,
    this.notes,
  });

  bool get isReadyForHarvest {
    if (expectedHarvest == null) return false;
    return DateTime.now().isAfter(expectedHarvest!);
  }
}
