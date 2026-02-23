class BreedingRecordEntity {
  final String? id;
  final String damAnimalId;
  final String? sireAnimalId;
  final DateTime matingDate;
  final DateTime expectedBirthDate;
  final String status;
  final String? method;
  final bool? success;
  final String? vet;
  final String? notes;

  BreedingRecordEntity({
    this.id,
    required this.damAnimalId,
    this.sireAnimalId,
    required this.matingDate,
    required this.expectedBirthDate,
    this.status = 'scheduled',
    this.method,
    this.success,
    this.vet,
    this.notes,
  }) {
    if (damAnimalId.trim().isEmpty) {
      throw ArgumentError('damAnimalId cannot be empty');
    }
    if (expectedBirthDate.isBefore(matingDate)) {
      throw ArgumentError('expectedBirthDate must be after matingDate');
    }
  }

  bool get isOverdue {
    if (status.toLowerCase() == 'completed') return false;
    return DateTime.now().isAfter(expectedBirthDate);
  }

  bool get isActivePregnancy => status.toLowerCase() != 'completed';
}
