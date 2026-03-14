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
    await db.delete('production_logs');
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

  test('summarizes setup readiness gaps from starter inventory', () async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now();

    await db.insert('inventory', {
      'item_name': 'Hay',
      'category': 'Animal Feed',
      'quantity': 0,
      'min_stock': 4,
      'unit': 'bales',
    });
    await db.insert('inventory', {
      'item_name': 'Maize Seed',
      'category': 'Seeds',
      'quantity': 1,
      'min_stock': 3,
      'unit': 'kg',
    });
    await db.insert('inventory', {
      'item_name': 'Fungicide',
      'category': 'Chemicals',
      'quantity': 2,
      'min_stock': 2,
      'unit': 'liters',
    });
    await db.insert('tasks', {
      'title': '7-day Dairy Cows production review',
      'status': 'pending',
      'source_event_type': 'setup',
      'due_date': now.add(const Duration(days: 5)).toIso8601String(),
    });
    await db.insert('crops', {
      'name': 'Tomatoes',
      'status': 'Growing',
      'expected_harvest_date':
          now.add(const Duration(days: 10)).toIso8601String(),
    });
    await db.insert('feeding_schedules', {
      'animal_id': 1,
      'feed_type': 'Hay',
      'quantity': 1,
      'unit': 'buckets',
      'time_of_day': 'Morning',
      'start_date': now.toIso8601String(),
      'notes': 'measure_label:1 morning bucket',
    });

    final summary = await LocalData.getFarmSummary();

    expect(summary['feedReadinessGaps'], 1);
    expect(summary['cropInputGaps'], 2);
    expect(summary['productionReviewsNext7Days'], 1);
    expect(summary['harvestReadyCrops'], 1);
    expect(
        summary['todaysFeedingPreview'], contains('Morning: 1 morning bucket'));
  });

  test('tracks output ready in stock and unsold production signals', () async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now();

    await db.insert('production_logs', {
      'animal_id': 'cow-1',
      'production_type': 'Milk',
      'quantity': 18,
      'unit': 'liters',
      'date_produced': now.toIso8601String(),
    });
    await db.insert('production_logs', {
      'animal_id': 'hen-1',
      'production_type': 'Eggs',
      'quantity': 24,
      'unit': 'pieces',
      'date_produced': now.toIso8601String(),
    });
    await db.insert('sales', {
      'product_name': 'Milk',
      'quantity': 10,
      'total_amount': 550,
      'sale_date': now.toIso8601String(),
      'payment_status': 'paid',
    });
    await db.insert('inventory', {
      'item_name': 'Milk',
      'category': 'Dairy',
      'quantity': 8,
      'unit': 'liters',
      'unit_price': 55,
      'total_value': 440,
    });
    await db.insert('inventory', {
      'item_name': 'Eggs',
      'category': 'Poultry',
      'quantity': 24,
      'unit': 'pieces',
      'unit_price': 15,
      'total_value': 360,
    });

    final summary = await LocalData.getFarmSummary();
    final insights = await LocalData.getOperationalInsights(limit: 10);

    expect(summary['milkSoldToday'], 10.0);
    expect(summary['milkStockOnHand'], 8.0);
    expect(summary['eggsStockOnHand'], 24.0);
    expect(summary['unsoldMilkToday'], 8.0);
    expect(summary['unsoldEggsToday'], 24.0);
    expect(summary['outputStockValue'], 800.0);
    expect(insights.map((item) => item.id), contains('output_ready'));
  });

  test('summarizes finance outlook, reminders, and freshness pressure',
      () async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now();

    await db.insert('inventory', {
      'item_name': 'Milk',
      'category': 'Dairy',
      'quantity': 12,
      'unit': 'liters',
      'min_stock': 0,
      'unit_price': 55,
      'total_value': 660,
      'last_restock': now.subtract(const Duration(hours: 20)).toIso8601String(),
    });
    await db.insert('inventory', {
      'item_name': 'Layer Mash',
      'category': 'Animal Feed',
      'quantity': 1,
      'min_stock': 4,
      'unit': 'bags',
      'unit_price': 1800,
    });
    await db.insert('sales', {
      'product_name': 'Eggs',
      'quantity': 10,
      'total_amount': 150,
      'sale_date': now.toIso8601String(),
      'payment_status': 'pending',
    });
    await db.insert('expenses', {
      'category': 'Feed',
      'item_name': 'Hay',
      'amount': 300,
      'expense_date': now.toIso8601String(),
    });

    final summary = await LocalData.getFarmSummary();
    final insights = await LocalData.getOperationalInsights(limit: 10);

    expect(summary['freshnessRiskCount'], 1);
    expect(summary['pendingCollectionsCount'], 1);
    expect(summary['pendingCollectionsValue'], 150.0);
    expect(summary['restockCostEstimate'], 5400.0);
    expect(summary['smartReminderCount'], greaterThanOrEqualTo(2));
    expect(summary['verificationScore'], greaterThan(0));
    expect(summary['marketplaceTrustScore'], greaterThan(0));
    expect(summary['lendingReadinessScore'], greaterThan(0));
    expect(insights.map((item) => item.id), contains('freshness_risk'));
  });
}
