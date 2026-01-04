import '../domain/repositories/repositories.dart';

class GetProducts {
  final MarketplaceRepository repository;
  GetProducts(this.repository);

  Future<List<Map<String, dynamic>>> execute() async => await repository.getProducts();
}

class AddProduct {
  final MarketplaceRepository repository;
  AddProduct(this.repository);

  Future<void> execute(Map<String, dynamic> product) async => await repository.addProduct(product);
}
