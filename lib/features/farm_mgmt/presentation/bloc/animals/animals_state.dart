part of 'animals_bloc.dart';

@freezed
class AnimalsState with _$AnimalsState {
  const factory AnimalsState.initial() = AnimalsInitial;
  const factory AnimalsState.loading() = AnimalsLoading;
  const factory AnimalsState.loaded({
    required List<AnimalEntity> animals,
  }) = AnimalsLoaded;
  const factory AnimalsState.error({
    required String message,
  }) = AnimalsError;
}
