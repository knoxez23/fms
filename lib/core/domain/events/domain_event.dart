abstract class DomainEvent {
  final DateTime occurredAt;

  DomainEvent({DateTime? occurredAt})
      : occurredAt = occurredAt ?? DateTime.now();
}
