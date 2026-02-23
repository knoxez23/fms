import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/production_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/production_log_entity.dart';

class ProductionLogState {
  final bool isLoading;
  final List<ProductionLogEntity> logs;
  final String? error;

  const ProductionLogState({
    required this.isLoading,
    required this.logs,
    this.error,
  });

  factory ProductionLogState.initial() =>
      const ProductionLogState(isLoading: false, logs: []);

  ProductionLogState copyWith({
    bool? isLoading,
    List<ProductionLogEntity>? logs,
    String? error,
  }) {
    return ProductionLogState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      error: error,
    );
  }
}

@injectable
class ProductionLogCubit extends Cubit<ProductionLogState> {
  final GetProductionLogs _getLogs;
  final AddProductionLog _addLog;
  final DeleteProductionLog _deleteLog;
  final Logger _logger = Logger();

  ProductionLogCubit(this._getLogs, this._addLog, this._deleteLog)
      : super(ProductionLogState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final logs = await _getLogs.execute();
      emit(state.copyWith(isLoading: false, logs: logs));
    } catch (e) {
      _logger.e('Failed to load production logs', error: e);
      emit(state.copyWith(isLoading: false, error: 'Failed to load logs'));
    }
  }

  Future<void> add(ProductionLogEntity log) async {
    try {
      await _addLog.execute(log);
      await load();
    } catch (e) {
      _logger.e('Failed to add production log', error: e);
      emit(state.copyWith(error: 'Failed to save production log'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteLog.execute(id);
      await load();
    } catch (e) {
      _logger.e('Failed to delete production log', error: e);
      emit(state.copyWith(error: 'Failed to delete production log'));
    }
  }
}
