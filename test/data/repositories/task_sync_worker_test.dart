import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/repositories/sync_worker.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:8000/api');
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
    await db.delete('task_sync_queue');
    await db.delete('task_delete_sync_queue');
    await db.delete('inventory');
    await db.delete('inventory_sync_queue');
    await db.delete('pending_sales');

    final dio = ApiService().dio;
    dio.interceptors.clear();
  });

  test('sync worker drains queued task create and marks task synced', () async {
    final now = DateTime.now().toIso8601String();
    final db = await DatabaseHelper().database;
    final localId = await db.insert('tasks', {
      'title': 'Irrigate',
      'status': 'pending',
      'is_synced': 0,
    });

    await LocalData.queueTaskAction(
      localId: localId,
      action: 'create',
      payload: {'title': 'Irrigate', 'status': 'pending'},
    );

    ApiService().dio.httpClientAdapter = _FakeAdapter((options) {
      if (options.method == 'POST' && options.path == '/tasks') {
        return ResponseBody.fromString(
          jsonEncode({
            'id': 501,
            'title': 'Irrigate',
            'status': 'pending',
            'created_at': now,
          }),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    SyncWorker().start(interval: const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    SyncWorker().stop();

    final pending = await db.query('task_sync_queue');
    expect(pending, isEmpty);

    final syncedTask = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [501],
    );
    expect(syncedTask, hasLength(1));
    expect(syncedTask.first['is_synced'], 1);

    final visibleTasks = await LocalData.getTasks();
    expect(
      visibleTasks.any((task) => task.id == 501 && task.title == 'Irrigate'),
      isTrue,
    );
  });

  test('sync worker falls back update->create when remote task missing',
      () async {
    final db = await DatabaseHelper().database;
    await db.insert('tasks', {
      'id': 44,
      'title': 'Spray crops',
      'status': 'pending',
      'is_synced': 0,
    });

    await LocalData.queueTaskAction(
      localId: 44,
      action: 'update',
      payload: {'title': 'Spray crops', 'status': 'pending'},
    );

    ApiService().dio.httpClientAdapter = _FakeAdapter((options) {
      if (options.method == 'PUT' && options.path == '/tasks/44') {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Not Found'}),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      if (options.method == 'POST' && options.path == '/tasks') {
        return ResponseBody.fromString(
          jsonEncode({
            'id': 900,
            'title': 'Spray crops',
            'status': 'pending',
          }),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    SyncWorker().start(interval: const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 800));
    SyncWorker().stop();

    final oldRow = await db.query('tasks', where: 'id = ?', whereArgs: [44]);
    expect(oldRow, isEmpty);

    final newRow = await db.query('tasks', where: 'id = ?', whereArgs: [900]);
    expect(newRow, hasLength(1));
    expect(newRow.first['is_synced'], 1);

    final pending = await db.query('task_sync_queue');
    expect(pending, isEmpty);
  });

  test('sync worker drains task delete queue on successful delete', () async {
    final db = await DatabaseHelper().database;
    await LocalData.queueTaskDelete(321);

    ApiService().dio.httpClientAdapter = _FakeAdapter((options) {
      if (options.method == 'DELETE' && options.path == '/tasks/321') {
        return ResponseBody.fromString('', 204);
      }
      return ResponseBody.fromString(
        jsonEncode({}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    SyncWorker().start(interval: const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    SyncWorker().stop();

    final pendingDeletes = await db.query('task_delete_sync_queue');
    expect(pendingDeletes, isEmpty);
  });

  test('sync worker treats task delete 404 as idempotent success', () async {
    final db = await DatabaseHelper().database;
    await LocalData.queueTaskDelete(777);

    ApiService().dio.httpClientAdapter = _FakeAdapter((options) {
      if (options.method == 'DELETE' && options.path == '/tasks/777') {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Not Found'}),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    SyncWorker().start(interval: const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    SyncWorker().stop();

    final pendingDeletes = await db.query('task_delete_sync_queue');
    expect(pendingDeletes, isEmpty);
  });
}
