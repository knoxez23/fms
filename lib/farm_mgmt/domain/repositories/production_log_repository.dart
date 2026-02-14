import '../entities/production_log_entity.dart';

abstract class ProductionLogRepository {
  Future<List<ProductionLogEntity>> getLogs();
  Future<ProductionLogEntity> addLog(ProductionLogEntity log);
  Future<void> deleteLog(String id);
}
