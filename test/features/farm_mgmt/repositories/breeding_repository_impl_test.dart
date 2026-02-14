import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/breeding_record_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/infrastructure/breeding_repository_impl.dart';

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
    await db.delete('breeding_records');
  });

  test('addRecord/getRecords/deleteRecord persist breeding records', () async {
    final repo = BreedingRepositoryImpl();

    final created = await repo.addRecord(
      BreedingRecordEntity(
        damAnimalId: '1',
        sireAnimalId: '2',
        matingDate: DateTime(2026, 1, 1),
        expectedBirthDate: DateTime(2026, 10, 8),
        status: 'scheduled',
        method: 'Artificial Insemination',
        success: true,
        vet: 'Dr. Kamau',
      ),
    );

    expect(created.id, isNotNull);

    final records = await repo.getRecords();
    expect(records, hasLength(1));
    expect(records.first.damAnimalId, equals('1'));
    expect(records.first.method, equals('Artificial Insemination'));
    expect(records.first.success, isTrue);

    await repo.deleteRecord(created.id!);
    final remaining = await repo.getRecords();
    expect(remaining, isEmpty);
  });
}
