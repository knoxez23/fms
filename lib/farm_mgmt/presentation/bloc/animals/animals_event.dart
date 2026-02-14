part of 'animals_bloc.dart';

@freezed
class AnimalsEvent with _$AnimalsEvent {
  const factory AnimalsEvent.load() = LoadAnimals;

  const factory AnimalsEvent.add({
    required AnimalEntity animal,
  }) = AddAnimalEvent;

  const factory AnimalsEvent.update({
    required AnimalEntity animal,
  }) = UpdateAnimalEvent;

  const factory AnimalsEvent.delete({
    required String id,
  }) = DeleteAnimalEvent;
}
