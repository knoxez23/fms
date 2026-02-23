import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/events/farm_domain_events.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/repositories/task_repository.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/features/inventory/domain/events/inventory_domain_events.dart';

import '../domain/entities/task_entity.dart';

@lazySingleton
class DomainEventSubscribers {
  final DomainEventBus _eventBus;
  final TaskRepository _taskRepository;
  final Logger _logger = Logger();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<String> _inflightTaskTitles = <String>{};

  bool _started = false;

  DomainEventSubscribers(this._eventBus, this._taskRepository);

  void start() {
    if (_started) return;
    _started = true;

    _subscriptions.add(
      _eventBus.on<AnimalBred>().listen((event) {
        _ensureTaskExists(
          title: 'Breeding follow-up: ${event.damAnimalId}',
          description:
              'Expected birth date: ${event.expectedBirthDate.toIso8601String().split('T').first}. Confirm nutrition and housing readiness.',
          dueDate: event.expectedBirthDate.subtract(const Duration(days: 14)),
          sourceEventType: 'breeding',
          sourceEventId:
              '${event.damAnimalId}:${event.expectedBirthDate.toIso8601String()}',
        );
      }),
    );

    _subscriptions.add(
      _eventBus.on<CropHarvested>().listen((event) {
        _ensureTaskExists(
          title: 'Harvest ${event.cropName}',
          description: 'Crop is ready for harvest.',
          dueDate: event.harvestedAt,
          sourceEventType: 'CropHarvested',
          sourceEventId: event.cropId ?? event.cropName,
        );
      }),
    );

    _subscriptions.add(
      _eventBus.on<InventoryLowStock>().listen((event) {
        _ensureTaskExists(
          title: 'Restock ${event.itemName}',
          description:
              'Low stock detected (${event.quantity} <= ${event.minStock}).',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          sourceEventType: 'InventoryLowStock',
          sourceEventId: event.itemId ?? event.itemName,
        );
      }),
    );

    _subscriptions.add(
      _eventBus.on<AnimalHealthAlert>().listen((event) {
        _ensureTaskExists(
          title: 'Health check: ${event.animalName}',
          description:
              'Animal status marked as ${event.status}. Schedule vet review and monitor feed/water intake.',
          dueDate: DateTime.now().add(const Duration(hours: 12)),
          sourceEventType: 'AnimalHealthAlert',
          sourceEventId: '${event.animalId}:${event.status}',
        );
      }),
    );

    _subscriptions.add(
      _eventBus.on<TaskCompleted>().listen((event) {
        _logger.i('Task completed event received: ${event.title}');
      }),
    );
  }

  Future<void> _ensureTaskExists({
    required String title,
    required String description,
    required DateTime dueDate,
    required String sourceEventType,
    required String sourceEventId,
  }) async {
    if (_inflightTaskTitles.contains(title)) return;
    _inflightTaskTitles.add(title);

    try {
      final tasks = await _taskRepository.getTasks();
      final exists = tasks.any(
        (task) =>
            (!task.isCompleted &&
                task.sourceEventType == sourceEventType &&
                task.sourceEventId == sourceEventId) ||
            (task.title.value == title && !task.isCompleted),
      );
      if (exists) return;

      await _taskRepository.addTask(
        TaskEntity(
          title: TaskTitle(title),
          description: description,
          dueDate: dueDate,
          sourceEventType: sourceEventType,
          sourceEventId: sourceEventId,
        ),
      );
    } catch (e) {
      _logger.e('Failed to process domain event task action', error: e);
    } finally {
      _inflightTaskTitles.remove(title);
    }
  }

  @disposeMethod
  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _started = false;
  }
}
