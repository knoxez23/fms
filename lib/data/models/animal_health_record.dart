class AnimalHealthRecord {
  final int? id;
  final int animalId;
  final String type;
  final String name;
  final String? notes;
  final String? treatedAt;
  final int? userId;

  AnimalHealthRecord({
    this.id,
    required this.animalId,
    required this.type,
    required this.name,
    this.notes,
    this.treatedAt,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'type': type,
      'name': name,
      'notes': notes,
      'treated_at': treatedAt,
      'user_id': userId,
    };
  }

  factory AnimalHealthRecord.fromMap(Map<String, dynamic> map) {
    return AnimalHealthRecord(
      id: map['id'] as int?,
      animalId: (map['animal_id'] as num).toInt(),
      type: (map['type'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      notes: map['notes']?.toString(),
      treatedAt: map['treated_at']?.toString(),
      userId: map['user_id'] as int?,
    );
  }
}
