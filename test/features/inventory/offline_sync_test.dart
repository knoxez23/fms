import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/features/inventory/infrastructure/inventory_repository_impl.dart';
import 'package:pamoja_twalima/data/services/inventory_service.dart';
import 'package:pamoja_twalima/data/services/connectivity_service.dart';

class MockInventoryService extends Mock implements InventoryService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

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
    await db.delete('inventory');
    await db.delete('inventory_sync_queue');
    await db.delete('inventory_delete_tombstones');
  });

  tearDown(() async {
    final db = await DatabaseHelper().database;
    await db.delete('inventory');
    await db.delete('inventory_sync_queue');
    await db.delete('inventory_delete_tombstones');
  });

  test('addItem queues create with client_uuid', () async {
    final repo = InventoryRepositoryImpl(
      MockInventoryService(),
      MockConnectivityService(),
    );

    final item = InventoryItem(
      itemName: 'Maize Seed',
      category: 'Seeds',
      quantity: 10,
      unit: 'kg',
      minStock: 2,
    );

    await repo.addItem(item);

    final db = await DatabaseHelper().database;
    final inventoryRows = await db.query('inventory');
    final queueRows = await db.query('inventory_sync_queue');

    expect(inventoryRows, hasLength(1));
    expect(queueRows, hasLength(1));

    final clientUuid = inventoryRows.first['client_uuid'];
    expect(clientUuid, isNotNull);

    final payload = jsonDecode(queueRows.first['payload'] as String)
        as Map<String, dynamic>;
    expect(payload['client_uuid'], equals(clientUuid));
    expect(queueRows.first['action'], equals('create'));
  });

  test('deleteItem removes pending actions for local-only items', () async {
    final repo = InventoryRepositoryImpl(
      MockInventoryService(),
      MockConnectivityService(),
    );

    final db = await DatabaseHelper().database;
    final localId = await db.insert('inventory', {
      'item_name': 'Fertilizer',
      'category': 'Inputs',
      'quantity': 5,
      'unit': 'kg',
      'min_stock': 1,
      'is_synced': 0,
      'server_id': null,
      'client_uuid': 'local-only-uuid',
    });

    await SyncDataRepository().queueInventoryAction(
      localId: localId,
      action: 'update',
      payload: {
        'item_name': 'Fertilizer',
        'category': 'Inputs',
        'quantity': 5,
        'unit': 'kg',
        'min_stock': 1,
      },
    );

    await repo.deleteItem(localId.toString());

    final remainingInventory = await db.query('inventory');
    final remainingQueue = await db.query('inventory_sync_queue');

    expect(remainingInventory, isEmpty);
    expect(remainingQueue, isEmpty);
  });

  test('pending delete prevents server item from being reinserted on sync',
      () async {
    final service = MockInventoryService();
    final connectivity = MockConnectivityService();
    when(() => connectivity.isOnline()).thenAnswer((_) async => true);
    when(() => service.list()).thenAnswer(
      (_) async => [
        {
          'id': 42,
          'client_uuid': 'to-delete-uuid',
          'item_name': 'Compost',
          'category': 'Inputs',
          'quantity': 10.0,
          'unit': 'kg',
          'min_stock': 2,
          'updated_at': DateTime.now().toIso8601String(),
        }
      ],
    );

    final repo = InventoryRepositoryImpl(service, connectivity);
    final db = await DatabaseHelper().database;

    await SyncDataRepository().queueInventoryAction(
      localId: 999,
      action: 'delete',
      payload: {'server_id': 42},
    );

    final items = await repo.getItems();

    expect(items, isEmpty);
    final rows = await db.query('inventory');
    expect(rows, isEmpty);
  });

  test('pending delete by client_uuid prevents server item reinsertion',
      () async {
    final service = MockInventoryService();
    final connectivity = MockConnectivityService();
    when(() => connectivity.isOnline()).thenAnswer((_) async => true);
    when(() => service.list()).thenAnswer(
      (_) async => [
        {
          'id': 88,
          'client_uuid': 'ghost-uuid',
          'item_name': 'Old Stock',
          'category': 'Inputs',
          'quantity': 3.0,
          'unit': 'kg',
          'min_stock': 1,
          'updated_at': DateTime.now().toIso8601String(),
        }
      ],
    );

    final repo = InventoryRepositoryImpl(service, connectivity);
    final db = await DatabaseHelper().database;

    await SyncDataRepository().queueInventoryAction(
      localId: 1001,
      action: 'delete',
      payload: {'client_uuid': 'ghost-uuid'},
    );

    final items = await repo.getItems();
    expect(items, isEmpty);
    expect(await db.query('inventory'), isEmpty);
  });

  test(
      'server item with matching client_uuid links existing local row (no duplicate)',
      () async {
    final service = MockInventoryService();
    final connectivity = MockConnectivityService();
    when(() => connectivity.isOnline()).thenAnswer((_) async => true);
    when(() => service.list()).thenAnswer(
      (_) async => [
        {
          'id': 77,
          'client_uuid': 'shared-uuid',
          'item_name': 'Seedlings',
          'category': 'Nursery',
          'quantity': 30.0,
          'unit': 'pieces',
          'min_stock': 5,
          'updated_at': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        }
      ],
    );

    final repo = InventoryRepositoryImpl(service, connectivity);
    final db = await DatabaseHelper().database;

    final localId = await db.insert('inventory', {
      'client_uuid': 'shared-uuid',
      'item_name': 'Seedlings',
      'category': 'Nursery',
      'quantity': 25.0,
      'unit': 'pieces',
      'min_stock': 5,
      'last_updated': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'server_id': null,
      'conflict': 0,
    });

    final items = await repo.getItems();
    expect(items, hasLength(1));

    final rows = await db.query('inventory');
    expect(rows, hasLength(1));
    expect(rows.first['id'], localId);
    expect(rows.first['server_id'], 77);
  });

  test('delete keeps remote identity in queued payload', () async {
    final repo = InventoryRepositoryImpl(
      MockInventoryService(),
      MockConnectivityService(),
    );
    final db = await DatabaseHelper().database;

    final localId = await db.insert('inventory', {
      'client_uuid': 'sync-delete-uuid',
      'item_name': 'Silage',
      'category': 'Feed',
      'quantity': 10.0,
      'unit': 'kg',
      'min_stock': 2,
      'is_synced': 1,
      'server_id': 55,
    });

    await repo.deleteItem(localId.toString());

    final queueRows = await db.query('inventory_sync_queue');
    expect(queueRows, hasLength(1));
    final payload = jsonDecode(queueRows.first['payload'] as String);
    expect(payload['server_id'], 55);
    expect(payload['client_uuid'], 'sync-delete-uuid');

    final tombstones = await db.query('inventory_delete_tombstones');
    expect(tombstones, hasLength(1));
    expect(tombstones.first['server_id'], 55);
    expect(tombstones.first['client_uuid'], 'sync-delete-uuid');
  });

  test(
      'delete tombstone prevents item reinsertion even when delete queue is gone',
      () async {
    final service = MockInventoryService();
    final connectivity = MockConnectivityService();
    when(() => connectivity.isOnline()).thenAnswer((_) async => true);
    when(() => service.list()).thenAnswer(
      (_) async => [
        {
          'id': 55,
          'client_uuid': 'sync-delete-uuid',
          'item_name': 'Silage',
          'category': 'Feed',
          'quantity': 10.0,
          'unit': 'kg',
          'min_stock': 2,
          'updated_at': DateTime.now().toIso8601String(),
        }
      ],
    );

    final repo = InventoryRepositoryImpl(service, connectivity);
    final db = await DatabaseHelper().database;

    final localId = await db.insert('inventory', {
      'client_uuid': 'sync-delete-uuid',
      'item_name': 'Silage',
      'category': 'Feed',
      'quantity': 10.0,
      'unit': 'kg',
      'min_stock': 2,
      'is_synced': 1,
      'server_id': 55,
    });

    await repo.deleteItem(localId.toString());
    await db.delete('inventory_sync_queue');

    final items = await repo.getItems();
    expect(items, isEmpty);
    expect(await db.query('inventory'), isEmpty);
  });

  test('unsynced local row is not overwritten by newer server item', () async {
    final service = MockInventoryService();
    final connectivity = MockConnectivityService();
    when(() => connectivity.isOnline()).thenAnswer((_) async => true);
    when(() => service.list()).thenAnswer(
      (_) async => [
        {
          'id': 91,
          'client_uuid': 'conflict-uuid',
          'item_name': 'Urea',
          'category': 'Inputs',
          'quantity': 50.0,
          'unit': 'kg',
          'min_stock': 5,
          'updated_at': DateTime.now().toIso8601String(),
        }
      ],
    );

    final repo = InventoryRepositoryImpl(service, connectivity);
    final db = await DatabaseHelper().database;

    final localId = await db.insert('inventory', {
      'client_uuid': 'conflict-uuid',
      'item_name': 'Urea',
      'category': 'Inputs',
      'quantity': 40.0,
      'unit': 'kg',
      'min_stock': 5,
      'server_id': 91,
      'is_synced': 0,
      'last_updated':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'conflict': 0,
    });

    await repo.getItems();

    final rows = await db.query(
      'inventory',
      where: 'id = ?',
      whereArgs: [localId],
    );
    expect(rows, hasLength(1));
    expect(rows.first['quantity'], 40.0);
    expect(rows.first['conflict'], 1);
  });

  test('queue coalesces create then update for same local id', () async {
    final repo = SyncDataRepository();
    final db = await DatabaseHelper().database;
    final localId = 5001;

    await repo.queueInventoryAction(
      localId: localId,
      action: 'create',
      payload: {
        'item_name': 'Hay',
        'category': 'Feed',
        'quantity': 10,
        'unit': 'bales',
      },
    );

    await repo.queueInventoryAction(
      localId: localId,
      action: 'update',
      payload: {
        'item_name': 'Hay',
        'category': 'Feed',
        'quantity': 15,
        'unit': 'bales',
      },
    );

    final rows = await db.query(
      'inventory_sync_queue',
      where: 'inventory_local_id = ?',
      whereArgs: [localId],
    );
    expect(rows, hasLength(1));
    expect(rows.first['action'], 'create');
    final payload = jsonDecode(rows.first['payload'] as String);
    expect(payload['quantity'], 15);
  });

  test('resolve conflict keep local clears conflict and queues sync', () async {
    final service = MockInventoryService();
    final connectivity = MockConnectivityService();
    final repo = InventoryRepositoryImpl(service, connectivity);
    final db = await DatabaseHelper().database;

    final localId = await db.insert('inventory', {
      'client_uuid': 'resolve-local-uuid',
      'item_name': 'Pellets',
      'category': 'Feed',
      'quantity': 12.0,
      'unit': 'kg',
      'min_stock': 3,
      'server_id': 203,
      'is_synced': 0,
      'conflict': 1,
      'last_updated': DateTime.now().toIso8601String(),
    });

    await repo.resolveConflictKeepLocal(localId.toString());

    final rows = await db.query('inventory', where: 'id = ?', whereArgs: [localId]);
    expect(rows.first['conflict'], 0);
    expect(rows.first['is_synced'], 0);

    final queueRows = await db.query(
      'inventory_sync_queue',
      where: 'inventory_local_id = ?',
      whereArgs: [localId],
    );
    expect(queueRows, hasLength(1));
    expect(queueRows.first['action'], 'update');
  });

  test('resolve conflict use server applies remote values and clears queue',
      () async {
    final service = MockInventoryService();
    final connectivity = MockConnectivityService();
    when(() => service.get(204)).thenAnswer(
      (_) async => {
        'id': 204,
        'client_uuid': 'resolve-server-uuid',
        'item_name': 'Starter Feed',
        'category': 'Feed',
        'quantity': 22.0,
        'unit': 'kg',
        'min_stock': 4,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );

    final repo = InventoryRepositoryImpl(service, connectivity);
    final db = await DatabaseHelper().database;

    final localId = await db.insert('inventory', {
      'client_uuid': 'resolve-server-uuid',
      'item_name': 'Starter Feed',
      'category': 'Feed',
      'quantity': 15.0,
      'unit': 'kg',
      'min_stock': 4,
      'server_id': 204,
      'is_synced': 0,
      'conflict': 1,
      'last_updated': DateTime.now().toIso8601String(),
    });

    await SyncDataRepository().queueInventoryAction(
      localId: localId,
      action: 'update',
      payload: {'quantity': 15},
    );

    await repo.resolveConflictUseServer(localId.toString());

    final rows = await db.query('inventory', where: 'id = ?', whereArgs: [localId]);
    expect(rows.first['quantity'], 22.0);
    expect(rows.first['conflict'], 0);
    expect(rows.first['is_synced'], 1);

    final queueRows = await db.query(
      'inventory_sync_queue',
      where: 'inventory_local_id = ?',
      whereArgs: [localId],
    );
    expect(queueRows, isEmpty);
  });
}
