/// Base class for all domain events in the application.
/// Domain events represent something that happened in the domain
/// that other parts of the application might be interested in.
abstract class DomainEvent {
  const DomainEvent();
}
