import '../value_objects/value_objects.dart';

class ProductEntity {
  final String? id;
  final ProductName name;
  final String category;
  final Price price;
  final double quantity;
  final String unit;

  ProductEntity({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  bool get isAvailable => quantity > 0;
}
