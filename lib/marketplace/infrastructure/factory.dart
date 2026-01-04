import '../domain/repositories/repositories.dart';
import '../application/application.dart';
import 'marketplace_repository_impl.dart';

class MarketplaceFactory {
  static MarketplaceRepository createRepository() => MarketplaceRepositoryImpl();

  static GetProducts createGetProducts() => GetProducts(createRepository());

  static AddProduct createAddProduct() => AddProduct(createRepository());
}
