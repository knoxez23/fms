part of 'marketplace_bloc.dart';

@freezed
class MarketplaceEvent with _$MarketplaceEvent {
  const factory MarketplaceEvent.load() = LoadMarketplace;

  const factory MarketplaceEvent.addProduct({
    required ProductEntity product,
  }) = AddMarketplaceProduct;

  const factory MarketplaceEvent.updateProduct({
    required ProductEntity product,
  }) = UpdateMarketplaceProduct;

  const factory MarketplaceEvent.deleteProduct({
    required String id,
  }) = DeleteMarketplaceProduct;
}
