import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/production_log_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/features/farm_mgmt/infrastructure/production_log_repository_impl.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = p.join(await getDatabasesPath(), 'pamoja_twalima.db');
    final file = File(dbPath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    await DatabaseHelper().database;
  });

  setUp(() async {
    final db = await DatabaseHelper().database;
    await db.delete('production_logs');
  });

  test('addLog/getLogs/deleteLog persist production records', () async {
    final repo = ProductionLogRepositoryImpl();

    final created = await repo.addLog(
      ProductionLogEntity(
        animalId: '1',
        productType: 'Milk',
        quantity: Quantity(18.5),
        unit: MeasurementUnit('liters'),
        recordedAt: DateTime(2026, 2, 13, 8, 30),
        quality: 'Good',
        notes: 'Morning milking',
      ),
    );

    expect(created.id, isNotNull);

    final logs = await repo.getLogs();
    expect(logs, hasLength(1));
    expect(logs.first.productType, equals('Milk'));
    expect(logs.first.quantity.value, equals(18.5));
    expect(logs.first.unit.value, equals('liters'));
    expect(logs.first.quality, equals('Good'));

    await repo.deleteLog(created.id!);
    final remaining = await repo.getLogs();
    expect(remaining, isEmpty);
  });

  test('updateLog persists edited production values', () async {
    final repo = ProductionLogRepositoryImpl();

    final created = await repo.addLog(
      ProductionLogEntity(
        animalId: '2',
        productType: 'Eggs',
        quantity: Quantity(12),
        unit: MeasurementUnit('pieces'),
        recordedAt: DateTime(2026, 2, 14, 9, 0),
        quality: 'Good',
        notes: 'Initial',
      ),
    );

    await repo.updateLog(
      ProductionLogEntity(
        id: created.id,
        animalId: '2',
        productType: 'Eggs',
        quantity: Quantity(18),
        unit: MeasurementUnit('pieces'),
        recordedAt: DateTime(2026, 2, 14, 9, 0),
        quality: 'Excellent',
        notes: 'Updated record',
      ),
    );

    final logs = await repo.getLogs();
    expect(logs, hasLength(1));
    expect(logs.first.quantity.value, equals(18));
    expect(logs.first.quality, equals('Excellent'));
    expect(logs.first.notes, equals('Updated record'));
  });
}
