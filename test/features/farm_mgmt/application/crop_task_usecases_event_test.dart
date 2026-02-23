import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/crop_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/task_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/crop_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/events/farm_domain_events.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/repositories/crop_repository.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/repositories/task_repository.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';

class _FakeCropRepository implements CropRepository {
  @override
  Future<CropEntity> addCrop(CropEntity crop) async => crop;

  @override
  Future<void> deleteCrop(String id) async {}

  @override
  Future<List<CropEntity>> getCrops() async => const [];

  @override
  Future<CropEntity> updateCrop(CropEntity crop) async => crop;
}

class _FakeTaskRepository implements TaskRepository {
  @override
  Future<TaskEntity> addTask(TaskEntity task) async => task;

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<TaskEntity>> getTasks() async => const [];

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async => task;
}

void main() {
  test('UpdateCrop publishes CropHarvested when crop is ready', () async {
    final bus = DomainEventBus();
    final useCase = UpdateCrop(_FakeCropRepository(), bus);
    final eventFuture = bus.on<CropHarvested>().first;

    await useCase.execute(
      CropEntity(
        id: 'crop-1',
        name: CropName('Maize'),
        expectedHarvest: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    final event = await eventFuture;
    expect(event.cropId, 'crop-1');
    expect(event.cropName, 'Maize');
  });

  test('UpdateTask publishes TaskCompleted when completed', () async {
    final bus = DomainEventBus();
    final useCase = UpdateTask(_FakeTaskRepository(), bus);
    final eventFuture = bus.on<TaskCompleted>().first;

    await useCase.execute(
      TaskEntity(
        id: 'task-1',
        title: TaskTitle('Vaccinate chickens'),
        isCompleted: true,
      ),
    );

    final event = await eventFuture;
    expect(event.taskId, 'task-1');
    expect(event.title, 'Vaccinate chickens');
  });
}
