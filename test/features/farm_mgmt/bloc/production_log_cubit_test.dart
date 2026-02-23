import 'package:flutter_test/flutter_test.dart';

import 'package:pamoja_twalima/features/farm_mgmt/application/production_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/production_log_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/repositories/production_log_repository.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/production/production_log_cubit.dart';

class InMemoryProductionLogRepository implements ProductionLogRepository {
  final List<ProductionLogEntity> _items = [];

  @override
  Future<ProductionLogEntity> addLog(ProductionLogEntity log) async {
    final entity = ProductionLogEntity(
      id: (_items.length + 1).toString(),
      animalId: log.animalId,
      productType: log.productType,
      quantity: log.quantity,
      unit: log.unit,
      recordedAt: log.recordedAt,
      quality: log.quality,
      notes: log.notes,
    );
    _items.insert(0, entity);
    return entity;
  }

  @override
  Future<void> deleteLog(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<ProductionLogEntity>> getLogs() async => List.of(_items);

  @override
  Future<void> updateLog(ProductionLogEntity log) async {
    final index = _items.indexWhere((item) => item.id == log.id);
    if (index == -1) return;
    _items[index] = log;
  }
}

void main() {
  test('ProductionLogCubit load/add/delete updates state', () async {
    final repo = InMemoryProductionLogRepository();
    final cubit = ProductionLogCubit(
      GetProductionLogs(repo),
      AddProductionLog(repo),
      DeleteProductionLog(repo),
    );

    await cubit.load();
    expect(cubit.state.logs, isEmpty);

    await cubit.add(
      ProductionLogEntity(
        animalId: '1',
        productType: 'Milk',
        quantity: Quantity(10),
        unit: MeasurementUnit('liters'),
        recordedAt: DateTime(2026, 2, 13),
      ),
    );
    expect(cubit.state.logs, hasLength(1));

    await cubit.delete(cubit.state.logs.first.id!);
    expect(cubit.state.logs, isEmpty);
  });
}
