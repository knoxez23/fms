part of 'sales_bloc.dart';

@freezed
class SalesEvent with _$SalesEvent {
  const factory SalesEvent.loadSales() = LoadSales;

  const factory SalesEvent.addSale({
    required SaleEntity sale,
  }) = AddSaleEvent;

  const factory SalesEvent.updateSale({
    required SaleEntity sale,
  }) = UpdateSaleEvent;

  const factory SalesEvent.deleteSale({
    required String id,
  }) = DeleteSaleEvent;
}
