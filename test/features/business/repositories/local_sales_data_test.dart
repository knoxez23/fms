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
    await db.delete('pending_sales');
    await db.delete('sales');
  });

  test('insert/update/delete sale in local storage', () async {
    final id = await LocalData.insertSale({
      'product_name': 'Milk',
      'quantity': 5,
      'unit': 'liters',
      'price': 80,
      'total_amount': 400,
      'customer_name': 'Alice',
      'sale_date': '2026-02-14T10:00:00.000',
      'payment_status': 'Pending',
      'notes': '',
    });

    await LocalData.updateSale(id, {
      'product_name': 'Milk',
      'quantity': 6,
      'unit': 'liters',
      'price': 80,
      'total_amount': 480,
      'customer_name': 'Alice',
      'sale_date': '2026-02-14T10:00:00.000',
      'payment_status': 'Paid',
      'notes': 'Updated',
    });

    final rows = await LocalData.getSales();
    expect(rows, hasLength(1));
    expect(rows.first['id'], id);
    expect(rows.first['quantity'], 6);
    expect(rows.first['payment_status'], 'Paid');

    await LocalData.deleteSale(id);
    final empty = await LocalData.getSales();
    expect(empty, isEmpty);
  });

  test('findSaleIdByPayload resolves existing row', () async {
    final id = await LocalData.insertSale({
      'product_name': 'Eggs',
      'quantity': 30,
      'unit': 'pieces',
      'price': 15,
      'total_amount': 450,
      'customer_name': 'Bob',
      'sale_date': '2026-02-14T12:00:00.000',
      'payment_status': 'Pending',
      'notes': '',
    });

    final found = await LocalData.findSaleIdByPayload({
      'product_name': 'Eggs',
      'quantity': 30,
      'unit': 'pieces',
      'price': 15,
      'total_amount': 450,
      'customer_name': 'Bob',
      'sale_date': '2026-02-14T12:00:00.000',
    });

    expect(found, id);
  });

  test('upsertSaleFromServer is idempotent by server_id', () async {
    final firstLocalId = await LocalData.upsertSaleFromServer({
      'id': 555,
      'product_name': 'Tomatoes',
      'quantity': 20,
      'unit': 'kg',
      'price': 100,
      'total_amount': 2000,
      'customer_name': 'Carol',
      'sale_date': '2026-02-14T13:00:00.000',
      'payment_status': 'Pending',
      'notes': '',
    });

    final secondLocalId = await LocalData.upsertSaleFromServer({
      'id': 555,
      'product_name': 'Tomatoes',
      'quantity': 25,
      'unit': 'kg',
      'price': 100,
      'total_amount': 2500,
      'customer_name': 'Carol',
      'sale_date': '2026-02-14T13:00:00.000',
      'payment_status': 'Paid',
      'notes': 'Updated',
    });

    expect(secondLocalId, firstLocalId);

    final rows = await LocalData.getSales();
    expect(rows, hasLength(1));
    expect(rows.first['server_id'], 555);
    expect(rows.first['quantity'], 25);
    expect(rows.first['payment_status'], 'Paid');
  });
}
