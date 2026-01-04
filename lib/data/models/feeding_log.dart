class FeedingLog {
  final int? id;
  final int animalId;
  final int? scheduleId;
  final String feedType;
  final double quantity;
  final String unit;
  final String fedAt;
  final String? fedBy;
  final String? notes;

  FeedingLog({
    this.id,
    required this.animalId,
    this.scheduleId,
    required this.feedType,
    required this.quantity,
    required this.unit,
    required this.fedAt,
    this.fedBy,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'schedule_id': scheduleId,
      'feed_type': feedType,
      'quantity': quantity,
      'unit': unit,
      'fed_at': fedAt,
      'fed_by': fedBy,
      'notes': notes,
    };
  }

  factory FeedingLog.fromMap(Map<String, dynamic> map) {
    return FeedingLog(
      id: map['id'],
      animalId: map['animal_id'],
      scheduleId: map['schedule_id'],
      feedType: map['feed_type'],
      quantity: map['quantity'],
      unit: map['unit'],
      fedAt: map['fed_at'],
      fedBy: map['fed_by'],
      notes: map['notes'],
    );
  }
}