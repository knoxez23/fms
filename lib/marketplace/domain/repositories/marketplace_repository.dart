abstract class MarketplaceRepository {
  Future<List<Map<String, dynamic>>> getProducts();
  Future<void> addProduct(Map<String, dynamic> product);
  Future<void> updateProduct(Map<String, dynamic> product);
  Future<void> deleteProduct(String id);
}
