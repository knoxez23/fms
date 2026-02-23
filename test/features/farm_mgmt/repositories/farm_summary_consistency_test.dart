import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
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
    await db.delete('tasks');
    await db.delete('animals');
    await db.delete('crops');
    await db.delete('inventory');
    await db.delete('sales');
  });

  test('farm summary pendingTasks matches non-completed task rows', () async {
    final db = await DatabaseHelper().database;

    await db.insert('tasks', {
      'title': 'Irrigate block A',
      'status': 'pending',
    });
    await db.insert('tasks', {
      'title': 'Vaccinate calves',
      'status': 'in_progress',
    });
    await db.insert('tasks', {
      'title': 'Clean shed',
      'status': 'completed',
    });

    final summary = await LocalData.getFarmSummary();
    expect(summary['pendingTasks'], 2);

    final upcoming = await LocalData.getUpcomingTasks(limit: 10);
    expect(
      upcoming.where((row) => row['status'] != 'completed').length,
      2,
    );
  });
}

