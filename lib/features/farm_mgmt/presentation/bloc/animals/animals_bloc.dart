import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/animal_entity.dart';
import '../../../application/animal_usecases.dart';

part 'animals_event.dart';
part 'animals_state.dart';
part 'animals_bloc.freezed.dart';

@injectable
class AnimalsBloc extends Bloc<AnimalsEvent, AnimalsState> {
  final GetAnimals _getAnimals;
  final AddAnimal _addAnimal;
  final UpdateAnimal _updateAnimal;
  final DeleteAnimal _deleteAnimal;
  final Logger _logger = Logger();

  AnimalsBloc(
    this._getAnimals,
    this._addAnimal,
    this._updateAnimal,
    this._deleteAnimal,
  ) : super(const AnimalsState.initial()) {
    on<LoadAnimals>(_onLoadAnimals);
    on<AddAnimalEvent>(_onAddAnimal);
    on<UpdateAnimalEvent>(_onUpdateAnimal);
    on<DeleteAnimalEvent>(_onDeleteAnimal);
  }

  Future<void> _onLoadAnimals(
    LoadAnimals event,
    Emitter<AnimalsState> emit,
  ) async {
    emit(const AnimalsState.loading());
    try {
      final animals = await _getAnimals.execute();
      emit(AnimalsState.loaded(animals: animals));
    } catch (e) {
      _logger.e('Failed to load animals', error: e);
      emit(const AnimalsState.error(message: 'Failed to load animals'));
    }
  }

  Future<void> _onAddAnimal(
    AddAnimalEvent event,
    Emitter<AnimalsState> emit,
  ) async {
    try {
      await _addAnimal.execute(event.animal);
      add(const AnimalsEvent.load());
    } catch (e) {
      _logger.e('Failed to add animal', error: e);
      emit(const AnimalsState.error(message: 'Failed to add animal'));
    }
  }

  Future<void> _onUpdateAnimal(
    UpdateAnimalEvent event,
    Emitter<AnimalsState> emit,
  ) async {
    try {
      await _updateAnimal.execute(event.animal);
      add(const AnimalsEvent.load());
    } catch (e) {
      _logger.e('Failed to update animal', error: e);
      emit(const AnimalsState.error(message: 'Failed to update animal'));
    }
  }

  Future<void> _onDeleteAnimal(
    DeleteAnimalEvent event,
    Emitter<AnimalsState> emit,
  ) async {
    try {
      await _deleteAnimal.execute(event.id);
      add(const AnimalsEvent.load());
    } catch (e) {
      _logger.e('Failed to delete animal', error: e);
      emit(const AnimalsState.error(message: 'Failed to delete animal'));
    }
  }
}
