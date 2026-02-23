import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/connectivity_service.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/entities/production_log_entity.dart';
import '../domain/repositories/production_log_repository.dart';
import '../domain/value_objects/value_objects.dart';

@LazySingleton(as: ProductionLogRepository)
class ProductionLogRepositoryImpl implements ProductionLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  ApiService? _apiService;

  ApiService get _api => _apiService ??= ApiService();

  Future<bool> _isOnline() async {
    try {
      return await _connectivityService.isOnline();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProductionLogEntity> addLog(ProductionLogEntity log) async {
    final parsedAnimalId = int.tryParse(log.animalId);
    if (parsedAnimalId != null && await _isOnline()) {
      try {
        final response = await _api.post(
          '/animal-production-logs',
          data: {
            'animal_id': parsedAnimalId,
            'type': log.productType,
            'quantity': log.quantity.value,
            'unit': log.unit.value,
            'produced_at': log.recordedAt.toIso8601String(),
            'notes': log.notes,
          },
        );
        final row = Map<String, dynamic>.from(response.data as Map);
        return await _upsertRemoteAsLocal(row, fallback: log);
      } catch (_) {
        // Fall through to local-first save.
      }
    }

    return _insertLocal(log);
  }

  @override
  Future<void> deleteLog(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    if (await _isOnline()) {
      try {
        await _api.delete('/animal-production-logs/$parsed');
      } catch (_) {
        // Continue local delete even if server call fails.
      }
    }
    final db = await _dbHelper.database;
    await db.delete('production_logs', where: 'id = ?', whereArgs: [parsed]);
  }

  @override
  Future<void> updateLog(ProductionLogEntity log) async {
    final db = await _dbHelper.database;
    final parsed = int.tryParse(log.id ?? '');
    if (parsed == null) return;

    if (await _isOnline()) {
      try {
        await _api.put(
          '/animal-production-logs/$parsed',
          data: {
            'animal_id': int.tryParse(log.animalId),
            'type': log.productType,
            'quantity': log.quantity.value,
            'unit': log.unit.value,
            'produced_at': log.recordedAt.toIso8601String(),
            'notes': log.notes,
          },
        );
      } catch (_) {
        // Keep local update; sync worker can reconcile later if needed.
      }
    }

    await db.update(
      'production_logs',
      {
        'animal_id': int.tryParse(log.animalId),
        'production_type': log.productType,
        'quantity': log.quantity.value,
        'unit': log.unit.value,
        'date_produced': log.recordedAt.toIso8601String(),
        'quality_rating': _qualityToRating(log.quality),
        'notes': log.notes,
      },
      where: 'id = ?',
      whereArgs: [parsed],
    );
  }

  @override
  Future<List<ProductionLogEntity>> getLogs() async {
    if (await _isOnline()) {
      try {
        final response = await _api.get('/animal-production-logs');
        final rows = List<Map<String, dynamic>>.from(
          (response.data as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
        for (final row in rows) {
          await _upsertRemoteAsLocal(row);
        }
      } catch (_) {
        // Fallback to local cache below.
      }
    }

    final db = await _dbHelper.database;
    final rows = await db.query('production_logs', orderBy: 'date_produced DESC');

    return rows.map((row) {
      final rating = row['quality_rating'] as int?;
      return ProductionLogEntity(
        id: row['id']?.toString(),
        animalId: (row['animal_id'] ?? '').toString(),
        productType: (row['production_type'] ?? 'Unknown').toString(),
        quantity: Quantity((row['quantity'] as num?)?.toDouble() ?? 0.1),
        unit: MeasurementUnit((row['unit'] ?? 'units').toString()),
        recordedAt: DateTime.tryParse((row['date_produced'] ?? '').toString()) ??
            DateTime.now(),
        quality: _ratingToQuality(rating),
        notes: row['notes']?.toString(),
      );
    }).toList();
  }

  Future<ProductionLogEntity> _insertLocal(ProductionLogEntity log) async {
    final db = await _dbHelper.database;
    final id = await db.insert('production_logs', {
      'animal_id': int.tryParse(log.animalId),
      'production_type': log.productType,
      'quantity': log.quantity.value,
      'unit': log.unit.value,
      'date_produced': log.recordedAt.toIso8601String(),
      'quality_rating': _qualityToRating(log.quality),
      'notes': log.notes,
    });
    return ProductionLogEntity(
      id: id.toString(),
      animalId: log.animalId,
      productType: log.productType,
      quantity: log.quantity,
      unit: log.unit,
      recordedAt: log.recordedAt,
      quality: log.quality,
      notes: log.notes,
    );
  }

  Future<ProductionLogEntity> _upsertRemoteAsLocal(
    Map<String, dynamic> row, {
    ProductionLogEntity? fallback,
  }) async {
    final db = await _dbHelper.database;
    final serverId = int.tryParse((row['id'] ?? '').toString());
    final producedAt = DateTime.tryParse(
      (row['produced_at'] ?? row['date_produced'] ?? '').toString(),
    );
    final localRow = {
      'id': serverId,
      'animal_id':
          row['animal_id'] ?? int.tryParse((fallback?.animalId ?? '').toString()),
      'production_type': row['type'] ?? row['production_type'] ?? fallback?.productType,
      'quantity': row['quantity'] ?? fallback?.quantity.value,
      'unit': row['unit'] ?? fallback?.unit.value,
      'date_produced': (producedAt ?? fallback?.recordedAt ?? DateTime.now())
          .toIso8601String(),
      'quality_rating': _qualityToRating(fallback?.quality),
      'notes': row['notes'] ?? fallback?.notes,
    };
    localRow.removeWhere((key, value) => value == null);

    if (serverId == null) {
      final insertedId = await db.insert('production_logs', localRow);
      return ProductionLogEntity(
        id: insertedId.toString(),
        animalId: (localRow['animal_id'] ?? '').toString(),
        productType: (localRow['production_type'] ?? 'Unknown').toString(),
        quantity:
            Quantity((localRow['quantity'] as num?)?.toDouble() ?? 0.0),
        unit: MeasurementUnit((localRow['unit'] ?? 'units').toString()),
        recordedAt: DateTime.parse(localRow['date_produced'].toString()),
        quality: fallback?.quality,
        notes: localRow['notes']?.toString(),
      );
    }

    await db.insert(
      'production_logs',
      localRow,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return ProductionLogEntity(
      id: serverId.toString(),
      animalId: (localRow['animal_id'] ?? '').toString(),
      productType: (localRow['production_type'] ?? 'Unknown').toString(),
      quantity: Quantity((localRow['quantity'] as num?)?.toDouble() ?? 0.0),
      unit: MeasurementUnit((localRow['unit'] ?? 'units').toString()),
      recordedAt: DateTime.parse(localRow['date_produced'].toString()),
      quality: fallback?.quality,
      notes: localRow['notes']?.toString(),
    );
  }

  int? _qualityToRating(String? quality) {
    if (quality == null) return null;
    switch (quality.toLowerCase()) {
      case 'excellent':
        return 5;
      case 'good':
        return 4;
      case 'fair':
        return 3;
      case 'poor':
        return 2;
      default:
        return null;
    }
  }

  String? _ratingToQuality(int? rating) {
    switch (rating) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Good';
      case 3:
        return 'Fair';
      case 2:
      case 1:
        return 'Poor';
      default:
        return null;
    }
  }
}
