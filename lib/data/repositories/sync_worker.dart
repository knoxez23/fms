import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'local_data.dart';
import '../services/sale_service.dart';
import 'inventory_sync_worker.dart';

class SyncWorker {
  static final SyncWorker _instance = SyncWorker._internal();
  factory SyncWorker() => _instance;

  Timer? _timer;
  bool _running = false;

  SyncWorker._internal();

  void start({Duration interval = const Duration(minutes: 2)}) {
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (_) => _runOnce());
    developer.log('SyncWorker started, interval: ${interval.inMinutes} minutes');
    // Run cleanup and sync immediately once
    _runOnce();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    developer.log('SyncWorker stopped');
  }

  Future<void> _runOnce() async {
    if (_running) return;
    _running = true;

    try {
      // First, cleanup invalid entries
      await _cleanupInvalidEntries();

      // Sync pending sales
      await _syncPendingSales();

      // Sync inventory items
      await _syncInventory();
    } catch (e, st) {
      developer.log('SyncWorker: unexpected error: $e', error: e, stackTrace: st);
    } finally {
      _running = false;
    }
  }

  /// Sync pending inventory items to the server
  Future<void> _syncInventory() async {
    try {
      final worker = InventorySyncWorker();
      await worker.sync();
      developer.log('SyncWorker: inventory sync completed');
    } catch (e, st) {
      developer.log('SyncWorker: inventory sync failed: $e', error: e, stackTrace: st);
    }
  }

  /// Sync pending sales to the server
  Future<void> _syncPendingSales() async {
    final pending = await LocalData.getPendingSales();
    if (pending.isEmpty) {
      return;
    }

    developer.log('SyncWorker: found ${pending.length} pending sales to sync');

    for (final row in pending) {
      final id = row['id'] as int;
      final payloadText = row['payload'] as String? ?? '';

      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(payloadText) as Map<String, dynamic>;
      } catch (e) {
        developer.log('SyncWorker: invalid JSON for pending sale id=$id, deleting');
        await LocalData.deletePendingSale(id);
        continue;
      }

      // Validate product_name before attempting sync
      if (!_isValidSale(payload)) {
        developer.log('SyncWorker: deleting invalid pending sale id=$id (validation failed)');
        await LocalData.deletePendingSale(id);
        continue;
      }

      // Transform payload to match Laravel expectations
      final transformedPayload = _transformPayloadForApi(payload);

      try {
        final result = await SaleService().create(transformedPayload);
        developer.log('SyncWorker: successfully synced pending sale id=$id, server returned: $result');
        
        // On success, remove from pending queue
        await LocalData.deletePendingSale(id);
        
        // Update local sales with server response (includes server-generated ID)
        if (result.containsKey('id')) {
          await LocalData.insertSale({
            ...payload,
            'id': result['id'], // Use server ID
          });
        }
        
        developer.log('SyncWorker: completed sync for pending sale id=$id');
      } catch (e, st) {
        developer.log(
          'SyncWorker: failed to sync pending sale id=$id: $e',
          error: e,
          stackTrace: st,
        );
        // Don't delete; will retry later
      }
    }
  }

  /// Clean up invalid pending sales entries
  Future<void> _cleanupInvalidEntries() async {
    try {
      final pending = await LocalData.getPendingSales();
      int deletedCount = 0;

      for (final row in pending) {
        final id = row['id'] as int;
        final payloadText = row['payload'] as String? ?? '';

        if (payloadText.isEmpty) {
          await LocalData.deletePendingSale(id);
          deletedCount++;
          continue;
        }

        Map<String, dynamic> payload;
        try {
          payload = jsonDecode(payloadText) as Map<String, dynamic>;
        } catch (e) {
          developer.log('Cleanup: invalid JSON for id=$id, deleting');
          await LocalData.deletePendingSale(id);
          deletedCount++;
          continue;
        }

        if (!_isValidSale(payload)) {
          developer.log('Cleanup: invalid sale data for id=$id, deleting');
          await LocalData.deletePendingSale(id);
          deletedCount++;
        }
      }

      if (deletedCount > 0) {
        developer.log('SyncWorker cleanup: removed $deletedCount invalid entries');
      }
    } catch (e, st) {
      developer.log('Cleanup failed: $e', error: e, stackTrace: st);
    }
  }

  /// Validate sale data
  bool _isValidSale(Map<String, dynamic> payload) {
    final productName = payload['product_name'];
    if (productName == null || productName is! String || productName.trim().isEmpty) {
      return false;
    }

    // Add more validation as needed
    final quantity = payload['quantity'];
    if (quantity == null || (quantity is num && quantity <= 0)) {
      return false;
    }

    return true;
  }

  /// Transform Flutter payload to match Laravel API expectations
  Map<String, dynamic> _transformPayloadForApi(Map<String, dynamic> payload) {
    return {
      'product_name': payload['product_name'],
      'quantity': payload['quantity'],
      'unit': payload['unit'],
      'price': payload['price'],
      'total_amount': payload['total_amount'],
      'customer_name': payload['customer_name'] ?? payload['customer'],
      'sale_date': payload['sale_date'] ?? payload['date'],
      'payment_status': payload['payment_status'],
      'notes': payload['notes'] ?? '',
      // user_id will be added by Laravel controller from auth()->id()
    };
  }
}