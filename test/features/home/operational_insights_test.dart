import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/features/home/domain/entities/dashboard_data.dart';

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
    await db.delete('inventory');
    await db.delete('crops');
    await db.delete('sales');
    await db.delete('feeding_schedules');
  });

  test('returns high-priority operational insights from live farm records',
      () async {
    final db = await DatabaseHelper().database;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final inThreeDays = today.add(const Duration(days: 3));

    await db.insert('tasks', {
      'title': 'Vaccinate calves',
      'status': 'pending',
      'due_date': yesterday.toIso8601String(),
    });
    await db.insert('inventory', {
      'item_name': 'Dairy meal',
      'quantity': 2,
      'min_stock': 5,
      'unit': 'kg',
    });
    await db.insert('crops', {
      'name': 'Tomatoes',
      'status': 'flowering',
      'expected_harvest_date': inThreeDays.toIso8601String(),
    });
    await db.insert('sales', {
      'product_name': 'Milk',
      'total_amount': 4200,
      'payment_status': 'pending',
    });
    await db.insert('feeding_schedules', {
      'animal_id': 1,
      'feed_type': 'Dairy meal',
      'quantity': 3,
      'unit': 'kg',
      'start_date': yesterday.toIso8601String(),
    });

    final insights = await LocalData.getOperationalInsights(limit: 10);

    expect(
        insights.map((item) => item.id),
        containsAll([
          'overdue_tasks',
          'low_stock',
          'harvest_window',
          'pending_collections',
          'active_feeding',
        ]));
    expect(insights.first.severity, OperationalInsightSeverity.critical);
  });

  test('returns stable insight when there are no urgent issues', () async {
    final insights = await LocalData.getOperationalInsights();

    expect(insights, hasLength(1));
    expect(insights.first.id, 'stable');
    expect(insights.first.severity, OperationalInsightSeverity.info);
  });
}
