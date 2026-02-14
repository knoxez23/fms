import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:pamoja_twalima/farm_mgmt/application/breeding_usecases.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/breeding_record_entity.dart';

class BreedingState {
  final bool isLoading;
  final List<BreedingRecordEntity> records;
  final String? error;

  const BreedingState({
    required this.isLoading,
    required this.records,
    this.error,
  });

  factory BreedingState.initial() =>
      const BreedingState(isLoading: false, records: []);

  BreedingState copyWith({
    bool? isLoading,
    List<BreedingRecordEntity>? records,
    String? error,
  }) {
    return BreedingState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      error: error,
    );
  }
}

@injectable
class BreedingCubit extends Cubit<BreedingState> {
  final GetBreedingRecords _getRecords;
  final AddBreedingRecord _addRecord;
  final DeleteBreedingRecord _deleteRecord;
  final Logger _logger = Logger();

  BreedingCubit(this._getRecords, this._addRecord, this._deleteRecord)
      : super(BreedingState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final records = await _getRecords.execute();
      emit(state.copyWith(isLoading: false, records: records));
    } catch (e) {
      _logger.e('Failed to load breeding records', error: e);
      emit(state.copyWith(isLoading: false, error: 'Failed to load records'));
    }
  }

  Future<void> add(BreedingRecordEntity record) async {
    try {
      await _addRecord.execute(record);
      await load();
    } catch (e) {
      _logger.e('Failed to add breeding record', error: e);
      emit(state.copyWith(error: 'Failed to save breeding record'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteRecord.execute(id);
      await load();
    } catch (e) {
      _logger.e('Failed to delete breeding record', error: e);
      emit(state.copyWith(error: 'Failed to delete breeding record'));
    }
  }
}
