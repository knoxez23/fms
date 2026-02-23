import 'package:injectable/injectable.dart';
import '../domain/entities/production_log_entity.dart';
import '../domain/repositories/production_log_repository.dart';

@lazySingleton
class GetProductionLogs {
  final ProductionLogRepository repository;
  GetProductionLogs(this.repository);

  Future<List<ProductionLogEntity>> execute() => repository.getLogs();
}

@lazySingleton
class AddProductionLog {
  final ProductionLogRepository repository;
  AddProductionLog(this.repository);

  Future<ProductionLogEntity> execute(ProductionLogEntity log) =>
      repository.addLog(log);
}

@lazySingleton
class DeleteProductionLog {
  final ProductionLogRepository repository;
  DeleteProductionLog(this.repository);

  Future<void> execute(String id) => repository.deleteLog(id);
}
