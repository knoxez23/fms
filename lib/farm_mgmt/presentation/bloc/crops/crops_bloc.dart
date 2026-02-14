import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/crop_entity.dart';
import '../../../application/crop_usecases.dart';

part 'crops_event.dart';
part 'crops_state.dart';
part 'crops_bloc.freezed.dart';

@injectable
class CropsBloc extends Bloc<CropsEvent, CropsState> {
  final GetCrops _getCrops;
  final AddCrop _addCrop;
  final UpdateCrop _updateCrop;
  final DeleteCrop _deleteCrop;
  final Logger _logger = Logger();

  CropsBloc(
    this._getCrops,
    this._addCrop,
    this._updateCrop,
    this._deleteCrop,
  ) : super(const CropsState.initial()) {
    on<LoadCrops>(_onLoad);
    on<AddCropEvent>(_onAdd);
    on<UpdateCropEvent>(_onUpdate);
    on<DeleteCropEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadCrops event, Emitter<CropsState> emit) async {
    emit(const CropsState.loading());
    try {
      final crops = await _getCrops.execute();
      emit(CropsState.loaded(crops: crops));
    } catch (e) {
      _logger.e('Failed to load crops', error: e);
      emit(const CropsState.error(message: 'Failed to load crops'));
    }
  }

  Future<void> _onAdd(AddCropEvent event, Emitter<CropsState> emit) async {
    try {
      await _addCrop.execute(event.crop);
      add(const CropsEvent.load());
    } catch (e) {
      _logger.e('Failed to add crop', error: e);
      emit(const CropsState.error(message: 'Failed to add crop'));
    }
  }

  Future<void> _onUpdate(
    UpdateCropEvent event,
    Emitter<CropsState> emit,
  ) async {
    try {
      await _updateCrop.execute(event.crop);
      add(const CropsEvent.load());
    } catch (e) {
      _logger.e('Failed to update crop', error: e);
      emit(const CropsState.error(message: 'Failed to update crop'));
    }
  }

  Future<void> _onDelete(
    DeleteCropEvent event,
    Emitter<CropsState> emit,
  ) async {
    try {
      await _deleteCrop.execute(event.id);
      add(const CropsEvent.load());
    } catch (e) {
      _logger.e('Failed to delete crop', error: e);
      emit(const CropsState.error(message: 'Failed to delete crop'));
    }
  }
}
