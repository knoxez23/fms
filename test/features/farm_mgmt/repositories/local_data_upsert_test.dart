import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/models/animal.dart';
import 'package:pamoja_twalima/data/models/crop.dart';
import 'package:pamoja_twalima/data/models/task.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseHelper().database;
  });

  setUp(() async {
    final db = await DatabaseHelper().database;
    await db.delete('animals');
    await db.delete('crops');
    await db.delete('tasks');
    await db.delete('task_sync_queue');
    await db.delete('task_delete_sync_queue');
  });

  test('upsertAnimal is idempotent by primary id', () async {
    await LocalData.upsertAnimal(
      Animal(
        id: 101,
        name: 'Cow A',
        type: 'cattle',
        weight: 220,
      ),
    );
    await LocalData.upsertAnimal(
      Animal(
        id: 101,
        name: 'Cow A Updated',
        type: 'cattle',
        weight: 245,
      ),
    );

    final rows = await LocalData.getAnimals();
    expect(rows, hasLength(1));
    expect(rows.first.name, 'Cow A Updated');
    expect(rows.first.weight, 245);
  });

  test('upsertCrop is idempotent by primary id', () async {
    await LocalData.upsertCrop(
      Crop(
        id: 202,
        name: 'Maize',
        plantedDate: '2026-02-01',
        area: 1.5,
        status: 'Growing',
      ),
    );
    await LocalData.upsertCrop(
      Crop(
        id: 202,
        name: 'Maize',
        variety: 'H6213',
        plantedDate: '2026-02-01',
        area: 2.0,
        status: 'Growing',
      ),
    );

    final rows = await LocalData.getCrops();
    expect(rows, hasLength(1));
    expect(rows.first.variety, 'H6213');
    expect(rows.first.area, 2.0);
  });

  test('upsertTask is idempotent by primary id', () async {
    await LocalData.upsertTask(
      Task(
        id: 303,
        title: 'Water crops',
        status: 'pending',
      ),
    );
    await LocalData.upsertTask(
      Task(
        id: 303,
        title: 'Water crops',
        status: 'completed',
      ),
    );

    final rows = await LocalData.getTasks();
    expect(rows, hasLength(1));
    expect(rows.first.status, 'completed');
  });

  test('insertTask marks local-only task as unsynced', () async {
    final id = await LocalData.insertTask(
      Task(
        title: 'Local task',
        status: 'pending',
      ),
    );

    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'tasks',
      columns: ['is_synced'],
      where: 'id = ?',
      whereArgs: [id],
    );
    expect(rows, hasLength(1));
    expect(rows.first['is_synced'], 0);
  });

  test('queueTaskDelete is idempotent by task_server_id', () async {
    await LocalData.queueTaskDelete(42);
    await LocalData.queueTaskDelete(42);

    final pending = await LocalData.getPendingTaskDeletes();
    expect(pending, hasLength(1));
    expect(pending.first['task_server_id'], 42);
  });

  test('queueTaskAction coalesces create then update for same task', () async {
    await LocalData.queueTaskAction(
      localId: 700,
      action: 'create',
      payload: {'title': 'Irrigate', 'status': 'pending'},
    );
    await LocalData.queueTaskAction(
      localId: 700,
      action: 'update',
      payload: {'title': 'Irrigate field A', 'status': 'pending'},
    );

    final pending = await LocalData.getPendingTaskActions();
    expect(pending, hasLength(1));
    expect(pending.first['action'], 'create');
  });
}
