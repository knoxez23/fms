import 'dart:async';

import 'package:injectable/injectable.dart';

import 'domain_event.dart';

@lazySingleton
class DomainEventBus {
  final StreamController<DomainEvent> _controller =
      StreamController<DomainEvent>.broadcast(sync: true);

  Stream<T> on<T extends DomainEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void publish(DomainEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  @disposeMethod
  Future<void> dispose() async {
    await _controller.close();
  }
}
