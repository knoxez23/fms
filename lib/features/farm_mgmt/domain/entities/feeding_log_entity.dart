class FeedingLogEntity {
  final int? id;
  final int animalId;
  final int? scheduleId;
  final int? inventoryId;
  final String feedType;
  final double quantity;
  final String unit;
  final DateTime fedAt;
  final String? fedBy;
  final String? notes;

  FeedingLogEntity({
    this.id,
    required this.animalId,
    this.scheduleId,
    this.inventoryId,
    required this.feedType,
    required this.quantity,
    required this.unit,
    required this.fedAt,
    this.fedBy,
    this.notes,
  });
}
