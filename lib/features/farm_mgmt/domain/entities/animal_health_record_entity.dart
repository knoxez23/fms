class AnimalHealthRecordEntity {
  final int? id;
  final int animalId;
  final String type;
  final String name;
  final String? notes;
  final DateTime? treatedAt;

  AnimalHealthRecordEntity({
    this.id,
    required this.animalId,
    required this.type,
    required this.name,
    this.notes,
    this.treatedAt,
  });
}
