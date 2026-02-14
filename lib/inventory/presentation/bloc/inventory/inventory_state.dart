part of 'inventory_bloc.dart';

@freezed
class InventoryState with _$InventoryState {
  const factory InventoryState.initial() = Initial;

  const factory InventoryState.loading() = Loading;

  const factory InventoryState.loaded({
    required List<InventoryItem> items,
    String? searchQuery,
    String? filterCategory,
  }) = Loaded;

  const factory InventoryState.error({
    required String message,
  }) = Error;
}
