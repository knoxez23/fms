class FeedingSchedule {
  final int? id;
  final int animalId;
  final int? inventoryId;
  final int? userId;
  final String feedType;
  final double quantity;
  final String unit;
  final String timeOfDay;
  final String? frequency;
  final String? startDate;
  final String? endDate;
  final String? notes;
  bool completed;

  FeedingSchedule({
    this.id,
    required this.animalId,
    this.inventoryId,
    this.userId,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'inventory_id': inventoryId,
      'user_id': userId,
      'feed_type': feedType,
      'quantity': quantity,
      'unit': unit,
      'time_of_day': timeOfDay,
      'frequency': frequency,
      'start_date': startDate,
      'end_date': endDate,
      'notes': notes,
      'completed': completed ? 1 : 0,
    };
  }

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) {
    return FeedingSchedule(
      id: map['id'],
      animalId: map['animal_id'],
      inventoryId: map['inventory_id'],
      userId: map['user_id'],
      feedType: map['feed_type'],
      quantity: map['quantity'],
      unit: map['unit'],
      timeOfDay: map['time_of_day'],
      frequency: map['frequency'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      notes: map['notes'],
      completed: map['completed'] == 1,
    );
  }
}
