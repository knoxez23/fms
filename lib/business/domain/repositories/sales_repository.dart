import '../entities/sale_entity.dart';

abstract class SalesRepository {
  Future<List<SaleEntity>> getSales();
  Future<SaleEntity> addSale(SaleEntity sale);
  Future<SaleEntity> updateSale(SaleEntity sale);
  Future<void> deleteSale(String id);
}
