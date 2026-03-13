class FeedingScheduleEntity {
  final int? id;
  final int animalId;
  final int? inventoryId;
  final String feedType;
  final double quantity;
  final String unit;
  final String timeOfDay;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final bool completed;

  FeedingScheduleEntity({
    this.id,
    required this.animalId,
    this.inventoryId,
    required this.feedType,
    required this.quantity,
    required this.unit,
    required this.timeOfDay,
    this.frequency,
    this.startDate,
    this.endDate,
    this.notes,
    this.completed = false,
  });
}
