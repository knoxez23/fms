import 'sale_entity.dart';

class SaleAggregate {
  final SaleEntity sale;

  SaleAggregate(this.sale) {
    _validate(sale);
  }

  void _validate(SaleEntity value) {
    if (value.productName.trim().isEmpty) {
      throw ArgumentError('Sale product name cannot be empty');
    }
    if (value.customer.trim().isEmpty) {
      throw ArgumentError('Sale customer cannot be empty');
    }

    final expected = value.quantity.value * value.pricePerUnit.value;
    final delta = (expected - value.totalAmount.value).abs();
    if (delta > 0.01) {
      throw ArgumentError('Sale total amount is inconsistent with quantity and unit price');
    }
  }
}
