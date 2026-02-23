import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/domain_event_subscribers.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/events/farm_domain_events.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/repositories/task_repository.dart';
import 'package:pamoja_twalima/features/inventory/domain/events/inventory_domain_events.dart';

class _InMemoryTaskRepository implements TaskRepository {
  final List<TaskEntity> items = [];

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    final saved = TaskEntity(
      id: (items.length + 1).toString(),
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      sourceEventType: task.sourceEventType,
      sourceEventId: task.sourceEventId,
    );
    items.add(saved);
    return saved;
  }

  @override
  Future<void> deleteTask(String id) async {
    items.removeWhere((task) => task.id == id);
  }

  @override
  Future<List<TaskEntity>> getTasks() async => List.of(items);

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async => task;
}

void main() {
  test('creates follow-up tasks from domain events', () async {
    final bus = DomainEventBus();
    final repo = _InMemoryTaskRepository();
    DomainEventSubscribers(bus, repo).start();

    bus.publish(
      AnimalBred(
        damAnimalId: 'dam-1',
        sireAnimalId: 'sire-1',
        expectedBirthDate: DateTime(2026, 11, 1),
      ),
    );
    bus.publish(
      InventoryLowStock(
        itemId: 'inv-1',
        itemName: 'Layer Feed',
        quantity: 2,
        minStock: 5,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(
      repo.items.any((t) => t.title.value.startsWith('Breeding follow-up:')),
      isTrue,
    );
    expect(
      repo.items.any((t) => t.sourceEventType == 'breeding'),
      isTrue,
    );
    expect(
      repo.items.any((t) => t.title.value == 'Restock Layer Feed'),
      isTrue,
    );
    expect(
      repo.items.any((t) => t.sourceEventType == 'InventoryLowStock'),
      isTrue,
    );
  });

  test('does not duplicate unresolved tasks for same event intent', () async {
    final bus = DomainEventBus();
    final repo = _InMemoryTaskRepository();
    DomainEventSubscribers(bus, repo).start();

    bus.publish(
      CropHarvested(
        cropId: 'crop-1',
        cropName: 'Tomatoes',
      ),
    );
    bus.publish(
      CropHarvested(
        cropId: 'crop-1',
        cropName: 'Tomatoes',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    final matches =
        repo.items.where((t) => t.title.value == 'Harvest Tomatoes').toList();
    expect(matches, hasLength(1));
  });
}
