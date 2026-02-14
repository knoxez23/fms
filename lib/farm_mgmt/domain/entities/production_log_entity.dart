import '../value_objects/measurement_unit.dart';
import '../value_objects/quantity.dart';

class ProductionLogEntity {
  final String? id;
  final String animalId;
  final String productType;
  final Quantity quantity;
  final MeasurementUnit unit;
  final DateTime recordedAt;
  final String? quality;
  final String? notes;

  ProductionLogEntity({
    this.id,
    required this.animalId,
    required this.productType,
    required this.quantity,
    required this.unit,
    required this.recordedAt,
    this.quality,
    this.notes,
  }) {
    if (animalId.trim().isEmpty) {
      throw ArgumentError('animalId cannot be empty');
    }
    if (productType.trim().isEmpty) {
      throw ArgumentError('productType cannot be empty');
    }
  }

  bool get isFutureDated => recordedAt.isAfter(DateTime.now());
}
