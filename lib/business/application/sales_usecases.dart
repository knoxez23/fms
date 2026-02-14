import 'package:injectable/injectable.dart';
import '../domain/entities/sale_aggregate.dart';
import '../domain/entities/sale_entity.dart';
import '../domain/repositories/sales_repository.dart';

@lazySingleton
class GetSales {
  final SalesRepository repository;
  GetSales(this.repository);

  Future<List<SaleEntity>> execute() async => repository.getSales();
}

@lazySingleton
class AddSale {
  final SalesRepository repository;
  AddSale(this.repository);

  Future<SaleEntity> execute(SaleEntity sale) async {
    SaleAggregate(sale);
    return repository.addSale(sale);
  }
}

@lazySingleton
class UpdateSale {
  final SalesRepository repository;
  UpdateSale(this.repository);

  Future<SaleEntity> execute(SaleEntity sale) async {
    SaleAggregate(sale);
    return repository.updateSale(sale);
  }
}

@lazySingleton
class DeleteSale {
  final SalesRepository repository;
  DeleteSale(this.repository);

  Future<void> execute(String id) async => repository.deleteSale(id);
}
