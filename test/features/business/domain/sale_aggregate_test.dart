import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/features/business/domain/entities/sale_aggregate.dart';
import 'package:pamoja_twalima/features/business/domain/entities/sale_entity.dart';
import 'package:pamoja_twalima/features/business/domain/value_objects/value_objects.dart';

void main() {
  test('rejects inconsistent total amount', () {
    expect(
      () => SaleAggregate(
        SaleEntity(
          productName: 'Milk',
          quantity: BusinessQuantity(10),
          unit: 'liters',
          pricePerUnit: Money(50),
          totalAmount: Money(400),
          customer: 'Alice',
          paymentStatus: 'paid',
          type: 'dairy',
        ),
      ),
      throwsArgumentError,
    );
  });
}
