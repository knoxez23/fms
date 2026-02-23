part of 'crops_bloc.dart';

@freezed
class CropsEvent with _$CropsEvent {
  const factory CropsEvent.load() = LoadCrops;

  const factory CropsEvent.add({
    required CropEntity crop,
  }) = AddCropEvent;

  const factory CropsEvent.update({
    required CropEntity crop,
  }) = UpdateCropEvent;

  const factory CropsEvent.delete({
    required String id,
  }) = DeleteCropEvent;
}
