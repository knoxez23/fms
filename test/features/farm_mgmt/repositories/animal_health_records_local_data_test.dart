import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/models/animal_health_record.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';

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
    await db.delete('animal_health_records');
  });

  test('insert/get/update/delete animal health records', () async {
    final insertedId = await LocalData.insertAnimalHealthRecord(
      AnimalHealthRecord(
        animalId: 1,
        type: 'checkup',
        name: 'General check',
        notes: 'Healthy appetite',
        treatedAt: DateTime(2026, 2, 20).toIso8601String(),
      ),
    );

    expect(insertedId, greaterThan(0));

    final records = await LocalData.getAnimalHealthRecords();
    expect(records, hasLength(1));
    expect(records.first.type, equals('checkup'));

    final updated = AnimalHealthRecord(
      id: insertedId,
      animalId: 1,
      type: 'treatment',
      name: 'Deworming',
      notes: 'Dose completed',
      treatedAt: DateTime(2026, 2, 21).toIso8601String(),
    );

    await LocalData.updateAnimalHealthRecord(updated);

    final afterUpdate = await LocalData.getAnimalHealthRecords();
    expect(afterUpdate, hasLength(1));
    expect(afterUpdate.first.name, equals('Deworming'));

    await LocalData.deleteAnimalHealthRecord(insertedId);
    final empty = await LocalData.getAnimalHealthRecords();
    expect(empty, isEmpty);
  });
}
