import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import '../domain/entities/production_log_entity.dart';
import '../domain/repositories/production_log_repository.dart';
import '../domain/value_objects/value_objects.dart';

@LazySingleton(as: ProductionLogRepository)
class ProductionLogRepositoryImpl implements ProductionLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<ProductionLogEntity> addLog(ProductionLogEntity log) async {
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

  @override
  Future<void> deleteLog(String id) async {
    final db = await _dbHelper.database;
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    await db.delete('production_logs', where: 'id = ?', whereArgs: [parsed]);
  }

  @override
  Future<List<ProductionLogEntity>> getLogs() async {
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
