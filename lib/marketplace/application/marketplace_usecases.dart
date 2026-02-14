import 'package:injectable/injectable.dart';
import '../domain/repositories/repositories.dart';
import '../domain/entities/product_entity.dart';
import '../domain/entities/inquiry_entity.dart';

@lazySingleton
class GetProducts {
  final MarketplaceRepository repository;
  GetProducts(this.repository);

  Future<List<ProductEntity>> execute() async => await repository.getProducts();
}

@lazySingleton
class AddProduct {
  final MarketplaceRepository repository;
  AddProduct(this.repository);

  Future<ProductEntity> execute(ProductEntity product) async =>
      await repository.addProduct(product);
}

@lazySingleton
class UpdateProduct {
  final MarketplaceRepository repository;
  UpdateProduct(this.repository);

  Future<ProductEntity> execute(ProductEntity product) async =>
      await repository.updateProduct(product);
}

@lazySingleton
class DeleteProduct {
  final MarketplaceRepository repository;
  DeleteProduct(this.repository);

  Future<void> execute(String id) async => await repository.deleteProduct(id);
}

@lazySingleton
class SubmitMarketplaceInquiry {
  final MarketplaceRepository repository;
  SubmitMarketplaceInquiry(this.repository);

  Future<InquiryEntity> execute(InquiryEntity inquiry) async =>
      await repository.submitInquiry(inquiry);
}
