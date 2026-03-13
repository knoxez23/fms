import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/services/local_session_service.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import '../domain/entities/breeding_record_entity.dart';
import '../domain/repositories/breeding_repository.dart';

@LazySingleton(as: BreedingRepository)
class BreedingRepositoryImpl implements BreedingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocalSessionService _localSessionService = LocalSessionService();

  @override
  Future<BreedingRecordEntity> addRecord(BreedingRecordEntity record) async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final id = await db.insert('breeding_records', {
      'dam_animal_id': int.tryParse(record.damAnimalId),
      'sire_animal_id': int.tryParse(record.sireAnimalId ?? ''),
      'mating_date': record.matingDate.toIso8601String(),
      'expected_birth_date': record.expectedBirthDate.toIso8601String(),
      'status': record.status,
      'method': record.method,
      'success': record.success == null ? null : (record.success! ? 1 : 0),
      'vet': record.vet,
      'notes': record.notes,
      'user_id': activeUserId,
    });

    return BreedingRecordEntity(
      id: id.toString(),
      damAnimalId: record.damAnimalId,
      sireAnimalId: record.sireAnimalId,
      matingDate: record.matingDate,
      expectedBirthDate: record.expectedBirthDate,
      status: record.status,
      method: record.method,
      success: record.success,
      vet: record.vet,
      notes: record.notes,
    );
  }

  @override
  Future<void> deleteRecord(String id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    await db.delete(
      'breeding_records',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [parsed] : [parsed, activeUserId],
    );
  }

  @override
  Future<List<BreedingRecordEntity>> getRecords() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final rows = await db.query(
      'breeding_records',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'mating_date DESC',
    );

    return rows.map((row) {
      return BreedingRecordEntity(
        id: row['id']?.toString(),
        damAnimalId: (row['dam_animal_id'] ?? '').toString(),
        sireAnimalId: row['sire_animal_id']?.toString(),
        matingDate: DateTime.tryParse((row['mating_date'] ?? '').toString()) ??
            DateTime.now(),
        expectedBirthDate:
            DateTime.tryParse((row['expected_birth_date'] ?? '').toString()) ??
                DateTime.now(),
        status: (row['status'] ?? 'scheduled').toString(),
        method: row['method']?.toString(),
        success: row['success'] == null
            ? null
            : ((row['success'] as num).toInt() == 1),
        vet: row['vet']?.toString(),
        notes: row['notes']?.toString(),
      );
    }).toList();
  }
}
