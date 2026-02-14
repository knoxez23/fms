class AuditEventEntity {
  final String id;
  final String eventType;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic> metadata;
  final DateTime occurredAt;

  const AuditEventEntity({
    required this.id,
    required this.eventType,
    required this.entityType,
    required this.entityId,
    required this.metadata,
    required this.occurredAt,
  });
}
