import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/core/services/local_notification_service.dart';
import 'package:pamoja_twalima/core/services/local_session_service.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  setUpAll(() async {
    LocalNotificationService.suppressPermissionRequestsForTests = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
      final key = call.arguments['key'] as String?;
      switch (call.method) {
        case 'read':
          return key == null ? null : storage[key];
        case 'write':
          if (key != null) {
            storage[key] = call.arguments['value'] as String;
          }
          return null;
        case 'delete':
          if (key != null) storage.remove(key);
          return null;
        case 'deleteAll':
          storage.clear();
          return null;
        case 'containsKey':
          return key != null && storage.containsKey(key);
        case 'readAll':
          return Map<String, String>.from(storage);
        default:
          return null;
      }
    });
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
    storage.clear();
    await LocalSessionService().clearSessionData();
  });

  test('switching authenticated user clears cached local data', () async {
    final db = await DatabaseHelper().database;
    final session = LocalSessionService();

    await session.prepareForAuthenticatedUser(
      userId: 101,
      email: 'first@example.com',
    );

    await db.insert('inventory', {
      'item_name': 'Dairy Meal',
      'category': 'Feed',
      'quantity': 12,
      'unit': 'kg',
    });
    await db.insert('sales', {
      'product_name': 'Milk',
      'type': 'Dairy',
      'total_amount': 1200,
      'customer_name': 'Buyer',
      'payment_status': 'paid',
    });
    await db.insert('task_sync_queue', {
      'task_local_id': 1,
      'action': 'create',
      'payload': '{}',
      'created_at': DateTime.now().toIso8601String(),
    });

    await session.prepareForAuthenticatedUser(
      userId: 202,
      email: 'second@example.com',
    );

    expect(await db.query('inventory'), isEmpty);
    expect(await db.query('sales'), isEmpty);
    expect(await db.query('task_sync_queue'), isEmpty);
    expect(await session.getActiveUserId(), 202);
  });
}
