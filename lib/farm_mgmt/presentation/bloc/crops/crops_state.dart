part of 'crops_bloc.dart';

@freezed
class CropsState with _$CropsState {
  const factory CropsState.initial() = CropsInitial;
  const factory CropsState.loading() = CropsLoading;
  const factory CropsState.loaded({
    required List<CropEntity> crops,
  }) = CropsLoaded;
  const factory CropsState.error({
    required String message,
  }) = CropsError;
}
