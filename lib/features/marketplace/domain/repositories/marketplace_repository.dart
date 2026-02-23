import '../entities/product_entity.dart';
import '../entities/inquiry_entity.dart';

abstract class MarketplaceRepository {
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity> addProduct(ProductEntity product);
  Future<ProductEntity> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String id);
  Future<InquiryEntity> submitInquiry(InquiryEntity inquiry);
}
