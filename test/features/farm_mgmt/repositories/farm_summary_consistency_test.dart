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
    await db.delete('expenses');
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

  test('farm summary includes expense-driven cash flow fields', () async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now().toIso8601String();

    await db.insert('sales', {
      'product_name': 'Milk',
      'total_amount': 6000.0,
      'sale_date': now,
      'payment_status': 'paid',
    });
    await db.insert('expenses', {
      'category': 'Feed',
      'item_name': 'Dairy meal',
      'amount': 2500.0,
      'expense_date': now,
    });

    final summary = await LocalData.getFarmSummary();

    expect(summary['monthlySales'], 6000.0);
    expect(summary['monthlyExpenses'], 2500.0);
    expect(summary['monthlyNetCashFlow'], 3500.0);
    expect(summary['expensesToday'], 2500.0);
    expect(summary['netCashFlowToday'], 3500.0);
  });

  test('business breakdown groups sales by type and expenses by category',
      () async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now().toIso8601String();

    await db.insert('sales', {
      'product_name': 'Milk',
      'type': 'Dairy',
      'total_amount': 4000.0,
      'customer_name': 'Buyer A',
      'sale_date': now,
      'payment_status': 'paid',
    });
    await db.insert('sales', {
      'product_name': 'Eggs',
      'type': 'Poultry',
      'total_amount': 1500.0,
      'customer_name': 'Buyer B',
      'sale_date': now,
      'payment_status': 'paid',
    });
    await db.insert('expenses', {
      'category': 'Feed',
      'item_name': 'Layer mash',
      'amount': 1800.0,
      'expense_date': now,
    });
    await db.insert('expenses', {
      'category': 'Transport',
      'item_name': 'Delivery fuel',
      'amount': 600.0,
      'expense_date': now,
    });

    final revenueByType = await LocalData.getRevenueByType();
    final expensesByCategory = await LocalData.getExpensesByCategory();

    expect(revenueByType.first['label'], 'Dairy');
    expect((revenueByType.first['total'] as num).toDouble(), 4000.0);
    expect(
      expensesByCategory.any(
        (row) =>
            row['label'] == 'Feed' &&
            (row['total'] as num).toDouble() == 1800.0,
      ),
      isTrue,
    );
  });
}
