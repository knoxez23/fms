part of 'marketplace_bloc.dart';

@freezed
class MarketplaceState with _$MarketplaceState {
  const factory MarketplaceState.initial() = MarketplaceInitial;
  const factory MarketplaceState.loading() = MarketplaceLoading;
  const factory MarketplaceState.loaded({
    required List<ProductEntity> products,
  }) = MarketplaceLoaded;
  const factory MarketplaceState.error({
    required String message,
  }) = MarketplaceError;
}
