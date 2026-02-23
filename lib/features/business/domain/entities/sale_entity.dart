import '../value_objects/value_objects.dart';

class SaleEntity {
  final String? id;
  final String productName;
  final BusinessQuantity quantity;
  final String unit;
  final Money pricePerUnit;
  final Money totalAmount;
  final DateTime? date;
  final String customer;
  final String? customerId;
  final String paymentStatus;
  final String type;
  final String? animal;
  final String? notes;

  SaleEntity({
    this.id,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.customer,
    this.customerId,
    required this.paymentStatus,
    required this.type,
    this.date,
    this.animal,
    this.notes,
  });

  bool get isPending => paymentStatus.toLowerCase() == 'pending';
}
