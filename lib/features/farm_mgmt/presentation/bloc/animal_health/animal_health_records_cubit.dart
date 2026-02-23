import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/animal_health_record_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_health_record_entity.dart';

class AnimalHealthRecordsState {
  final bool isLoading;
  final List<AnimalHealthRecordEntity> records;
  final String? error;

  const AnimalHealthRecordsState({
    required this.isLoading,
    required this.records,
    this.error,
  });

  factory AnimalHealthRecordsState.initial() =>
      const AnimalHealthRecordsState(isLoading: false, records: []);

  AnimalHealthRecordsState copyWith({
    bool? isLoading,
    List<AnimalHealthRecordEntity>? records,
    String? error,
  }) {
    return AnimalHealthRecordsState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      error: error,
    );
  }
}

class AnimalHealthRecordsCubit extends Cubit<AnimalHealthRecordsState> {
  final GetAnimalHealthRecords _getRecords;
  final AddAnimalHealthRecord _addRecord;
  final UpdateAnimalHealthRecord _updateRecord;
  final DeleteAnimalHealthRecord _deleteRecord;
  final Logger _logger = Logger();

  AnimalHealthRecordsCubit(
    this._getRecords,
    this._addRecord,
    this._updateRecord,
    this._deleteRecord,
  ) : super(AnimalHealthRecordsState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final records = await _getRecords.execute();
      emit(state.copyWith(isLoading: false, records: records));
    } catch (e) {
      _logger.e('Failed to load animal health records', error: e);
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load health records',
      ));
    }
  }

  Future<void> add(AnimalHealthRecordEntity record) async {
    try {
      await _addRecord.execute(record);
      await load();
    } catch (e) {
      _logger.e('Failed to add animal health record', error: e);
      emit(state.copyWith(error: 'Failed to save health record'));
    }
  }

  Future<void> update(AnimalHealthRecordEntity record) async {
    try {
      await _updateRecord.execute(record);
      await load();
    } catch (e) {
      _logger.e('Failed to update animal health record', error: e);
      emit(state.copyWith(error: 'Failed to update health record'));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _deleteRecord.execute(id);
      await load();
    } catch (e) {
      _logger.e('Failed to delete animal health record', error: e);
      emit(state.copyWith(error: 'Failed to delete health record'));
    }
  }
}
