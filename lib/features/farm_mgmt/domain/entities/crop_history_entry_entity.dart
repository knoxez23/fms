class CropHistoryEntryEntity {
  final String? id;
  final String cropId;
  final String eventType;
  final String description;
  final DateTime recordedAt;

  CropHistoryEntryEntity({
    this.id,
    required this.cropId,
    required this.eventType,
    required this.description,
    required this.recordedAt,
  }) {
    if (cropId.trim().isEmpty) {
      throw ArgumentError('cropId cannot be empty');
    }
    if (eventType.trim().isEmpty) {
      throw ArgumentError('eventType cannot be empty');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError('description cannot be empty');
    }
  }
}
